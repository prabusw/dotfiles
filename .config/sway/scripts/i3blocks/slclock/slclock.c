#include <stdio.h>
#include <stdlib.h>
#include <sys/timerfd.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>
#include <poll.h>
#include <signal.h>

int main() {
    char *click_script = getenv("CLICK_SCRIPT");
    signal(SIGCHLD, SIG_IGN);

    struct timespec now;
    int tfd = timerfd_create(CLOCK_REALTIME, 0);
    clock_gettime(CLOCK_REALTIME, &now);

    time_t next_minute = now.tv_sec - (now.tv_sec % 60) + 60;

    struct itimerspec timer = {
        .it_value = { .tv_sec = next_minute, .tv_nsec = 0 },
        .it_interval = { .tv_sec = 60, .tv_nsec = 0 }
    };

    timerfd_settime(tfd, TFD_TIMER_ABSTIME, &timer, NULL);

    struct pollfd fds[2] = {
        { STDIN_FILENO, POLLIN, 0 },
        { tfd,          POLLIN, 0 }
    };

    uint64_t expirations;
    char buffer[sizeof("23:59")];

    do {
        clock_gettime(CLOCK_REALTIME, &now);
        struct tm *time_info = localtime(&now.tv_sec);
        strftime(buffer, sizeof(buffer), "%H:%M", time_info);
        puts(buffer);
        fflush(stdout);

        if (poll(fds, 2, -1) > 0) {
            if (fds[0].revents & POLLIN) {
                char click[128];
                if (fgets(click, sizeof(click), stdin) && click_script) {
                    if (!fork()) {
                        execlp(click_script, click_script, NULL);
                        _exit(1);
                    }
                }
            }
        }
    }
    while (!(fds[1].revents & POLLIN) || read(tfd, &expirations, sizeof(expirations)) == sizeof(expirations));

    return 0;
}
