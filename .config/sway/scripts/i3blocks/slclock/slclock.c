#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>
#include <string.h>
#include <signal.h>

// Volatile flag for signal handling
static volatile sig_atomic_t running = 1;

static void handle_signal(int sig) {
    (void)sig;  // Unused parameter
    running = 0;
}

// Compile with -DNOHELP to exclude help text and reduce binary size
#ifndef NOHELP
static void print_help(const char *progname) {
    printf("slclock - simple/suckless/statusline clock\n\n");
    printf("USAGE:\n");
    printf("  %s [FORMAT] [LABEL] [CLICK_ARGS...]\n\n", progname);

    printf("ARGUMENTS:\n");
    printf("  FORMAT       strftime format string (default: %%H:%%M:%%S)\n");
    printf("  LABEL        optional prefix text (default: empty)\n");
    printf("  CLICK_ARGS   arguments passed to CLICK_SCRIPT on mouse events\n\n");

    printf("ENVIRONMENT VARIABLES:\n");
    printf("  DATEFMT      time format (fallback if FORMAT not provided)\n");
    printf("  LABEL        prefix label (fallback if LABEL not provided)\n");
    printf("  CLICK_SCRIPT script to execute on click events\n\n");

    printf("PRIORITY:\n");
    printf("  CLI arguments > Environment variables > Defaults\n\n");

    printf("ADAPTIVE UPDATES:\n");
    printf("  Automatically determines update interval from format:\n");
    printf("    - Formats with seconds (%%S, %%T): updates every 1 second\n");
    printf("    - Formats with minutes (%%M, %%R): updates every 60 seconds\n");
    printf("    - Formats with hours (%%H, %%I):   updates every 3600 seconds\n");
    printf("    - Date-only formats:              updates every 86400 seconds\n");
    printf("  Updates are aligned to wall-clock boundaries for efficiency.\n\n");

    printf("EXAMPLES:\n");
    printf("  # Standalone usage\n");
    printf("  %s '%%H:%%M'\n", progname);
    printf("  %s '%%I:%%M %%p' '🕐 '\n", progname);
    printf("  %s '%%Y-%%m-%%d %%H:%%M:%%S'\n\n", progname);

    printf("  # With click handler\n");
    printf("  CLICK_SCRIPT=~/my-script %s '%%H:%%M' '' --action\n\n", progname);

    printf("  # i3blocks configuration\n");
    printf("  [clock]\n");
    printf("  command=%s\n", progname);
    printf("  interval=persist\n");
    printf("  DATEFMT=+%%H:%%M\n");
    printf("  LABEL=📅 \n");
    printf("  CLICK_SCRIPT=~/.config/sway/scripts/calendar\n\n");

    printf("  # Waybar configuration\n");
    printf("  \"custom/clock\": {\n");
    printf("    \"exec\": \"%s '%%H:%%M'\",\n", progname);
    printf("    \"interval\": \"once\"\n");
    printf("  }\n\n");

    printf("FORMAT SPECIFIERS:\n");
    printf("  Common strftime formats:\n");
    printf("    %%H  Hour (00-23)          %%M  Minute (00-59)\n");
    printf("    %%I  Hour (01-12)          %%S  Second (00-59)\n");
    printf("    %%p  AM/PM                 %%A  Weekday name\n");
    printf("    %%Y  Year (4-digit)        %%m  Month (01-12)\n");
    printf("    %%d  Day of month (01-31)  %%B  Month name\n");
    printf("    %%T  Time (%%H:%%M:%%S)        %%R  Time (%%H:%%M)\n\n");

    printf("FEATURES:\n");
    printf("  - Minimal CPU usage via adaptive sleep intervals\n");
    printf("  - Wall-clock aligned updates (updates at :00 for minute formats)\n");
    printf("  - Non-blocking click handling with fork/exec\n");
    printf("  - Automatic child process cleanup (no zombie processes)\n");
    printf("  - Output deduplication (only updates when display changes)\n");
    printf("  - Graceful shutdown on SIGTERM, SIGINT (Ctrl+C), SIGHUP\n");
    printf("  - Auto-exit when parent process dies (POLLHUP detection)\n");
    printf("  - Works as both standalone tool and status bar component\n\n");

    printf("AUTHORS:\n");
    printf("  Originally designed for i3blocks/sway integration\n");
    printf("  Optimized for minimal wake-ups and CPU efficiency\n\n");
}
#endif

int get_update_interval(const char *format) {
    if (strstr(format, "%S") || strstr(format, "%s") || strstr(format, "%T"))
        return 1;
    if (strstr(format, "%M") || strstr(format, "%R"))
        return 60;
    if (strstr(format, "%H") || strstr(format, "%I") || strstr(format, "%k") || strstr(format, "%l"))
        return 3600;
    return 86400;
}

long ms_until_next_update(int interval) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    if (interval == 86400) {
        // Align to local midnight, not UTC midnight
        time_t now = ts.tv_sec;
        struct tm tm;
        localtime_r(&now, &tm);
        int sec_since_midnight = tm.tm_hour * 3600 + tm.tm_min * 60 + tm.tm_sec;
        long ms = (86400 - sec_since_midnight) * 1000L - ts.tv_nsec / 1000000;
        return ms > 0 ? ms : 1;
    }
    long epoch_ms = (long)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
    long ms = interval * 1000 - (epoch_ms % (interval * 1000));
    return ms > 0 ? ms : 1;
}

int main(int argc, char *argv[]) {
#ifndef NOHELP
    // Show help
    if (argc > 1 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)) {
        print_help(argv[0]);
        return 0;
    }
#endif

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
    struct pollfd fds[1] = {{STDIN_FILENO, POLLIN, 0}};
    char last[128] = "";

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

        long ms = ms_until_next_update(interval);
        if (ms <= 0) ms = 1;
        // Add 10ms padding so the scheduler safely crosses
        // into the next minute boundary before reading time
        ms += 10;

        int ret = poll(fds, 1, ms);

        // Check if we should exit due to signal
        if (!running) {
            break;
        }

        if (ret > 0) {
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

    return 0;
}
