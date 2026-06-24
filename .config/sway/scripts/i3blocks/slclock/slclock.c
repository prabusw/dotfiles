#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>
#include <string.h>
#include <signal.h>
#include <sys/timerfd.h>
#include <stdint.h>

// Volatile flag for signal handling
static volatile sig_atomic_t running = 1;

static void handle_signal(int sig) {
    (void)sig;  // Unused parameter
    running = 0;
}

int get_update_interval(const char *format) {
    if (strstr(format, "%S") || strstr(format, "%s") || strstr(format, "%T"))
        return 1;
    if (strstr(format, "%M") || strstr(format, "%R"))
        return 60;
    if (strstr(format, "%H") || strstr(format, "%I") || strstr(format, "%k") || strstr(format, "%l"))
        return 3600;
    return 86400;
}

int main(int argc, char *argv[]) {

    // Priority: CLI arg > env var > default
    char *format = NULL;
    char *label = NULL;
    char *click_script = getenv("CLICK_SCRIPT");

    // Parse arguments
    if (argc > 1) {
        format = argv[1];
        if (argc > 2) label = argv[2];
    } else {
        format = getenv("DATEFMT");
    }

    // Fallback to environment for label if not provided via CLI
    if (label == NULL) {
        label = getenv("LABEL");
    }

    // Defaults
    if (format == NULL || format[0] == '\0') {
        format = "%H:%M:%S";
    }

    // Skip leading '+' (common in date command usage)
    if (format[0] == '+') {
        format++;
    }

    if (label == NULL) {
        label = "";
    }

    // Set up signal handlers for graceful shutdown
    signal(SIGTERM, handle_signal);
    signal(SIGINT, handle_signal);
    signal(SIGHUP, handle_signal);

    // Prevent zombie processes from click script children
    signal(SIGCHLD, SIG_IGN);

    // Line buffering for instant output
    setvbuf(stdout, NULL, _IOLBF, 0);

    int interval = get_update_interval(format);
    char last[128] = "";

    // Create timer aligned to next wall-clock boundary
    int tfd = timerfd_create(CLOCK_REALTIME, TFD_CLOEXEC | TFD_NONBLOCK);
    struct timespec now_ts;
    clock_gettime(CLOCK_REALTIME, &now_ts);
    long next = ((now_ts.tv_sec / interval) + 1) * interval;
    struct itimerspec its = {
        .it_value    = { .tv_sec = next, .tv_nsec = 10000000 }, // +10ms padding
        .it_interval = { .tv_sec = interval, .tv_nsec = 0 }
    };
    timerfd_settime(tfd, TFD_TIMER_ABSTIME, &its, NULL);

    struct pollfd fds[2] = {
        { STDIN_FILENO, POLLIN, 0 },
        { tfd,          POLLIN, 0 }
    };

    while (running) {
        time_t now = time(NULL);
        struct tm tm_info;

        if (localtime_r(&now, &tm_info) != NULL) {
            char buf[128];

            if (strftime(buf, sizeof(buf), format, &tm_info) > 0) {
                if (strcmp(buf, last) != 0) {
                    printf("%s%s\n", label, buf);
                    strncpy(last, buf, sizeof(last) - 1);
                    last[sizeof(last) - 1] = '\0';
                }
            }
        }

        int ret = poll(fds, 2, -1);

        // Check if we should exit due to signal
        if (!running) {
            break;
        }

        if (ret > 0) {
            if (fds[1].revents & POLLIN) {
                uint64_t exp;
                read(tfd, &exp, sizeof(exp));
            }
            // Check for stdin closure (bar shutdown/restart)
            if (fds[0].revents & (POLLHUP | POLLERR | POLLNVAL)) {
                break;  // Exit cleanly when parent dies
            }

            // Handle click events
            if (fds[0].revents & POLLIN) {
                char click[128];
                if (fgets(click, sizeof(click), stdin) == NULL) {
                    break;  // EOF on stdin, parent likely died
                }

                if (click_script) {
                    pid_t pid = fork();
                    if (pid == 0) {
                        // Pass any extra CLI arguments to the click script
                        if (argc > 3) {
                            // Build argv array: script + args from argv[3..] + NULL
                            char *script_argv[32];  // Max 32 args
                            int arg_count = 0;

                            script_argv[arg_count++] = click_script;
                            for (int i = 3; i < argc && arg_count < 31; i++) {
                                script_argv[arg_count++] = argv[i];
                            }
                            script_argv[arg_count] = NULL;

                            execvp(click_script, script_argv);
                        } else {
                            // No extra args, just run the script
                            execlp(click_script, click_script, NULL);
                        }
                        _exit(1);
                    }
                }
            }
        }
    }
    close(tfd);
    return 0;
}
