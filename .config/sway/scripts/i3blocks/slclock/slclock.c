#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <poll.h>
#include <string.h>
#include <sys/timerfd.h>
#include <stdint.h>

int get_interval(const char *fmt) {
    if (strstr(fmt, "%S") || strstr(fmt, "%T")) return 1;
    if (strstr(fmt, "%M") || strstr(fmt, "%R")) return 60;
    if (strstr(fmt, "%H") || strstr(fmt, "%I")) return 3600;
    return 86400;
}

int main(int argc, char *argv[]) {
    const char *fmt = argc > 1 ? argv[1] : "%H:%M:%S";
    if (fmt[0] == '+') fmt++;

    int interval = get_interval(fmt);

    int tfd = timerfd_create(CLOCK_REALTIME, TFD_CLOEXEC);
    struct timespec now;
    clock_gettime(CLOCK_REALTIME, &now);
    long next = ((now.tv_sec / interval) + 1) * interval;
    struct itimerspec its = {
        .it_value    = { .tv_sec = next, .tv_nsec = 10000000 },
        .it_interval = { .tv_sec = interval, .tv_nsec = 0 }
    };
    timerfd_settime(tfd, TFD_TIMER_ABSTIME, &its, NULL);

    struct pollfd fds[2] = {
        { STDIN_FILENO, POLLIN, 0 },
        { tfd,          POLLIN, 0 }
    };

    setvbuf(stdout, NULL, _IOLBF, 0);
    char last[128] = "";

    while (1) {
        time_t t = time(NULL);
        struct tm tm;
        localtime_r(&t, &tm);
        char buf[128];
        if (strftime(buf, sizeof(buf), fmt, &tm) > 0) {
            if (strcmp(buf, last) != 0) {
                puts(buf);
                strncpy(last, buf, sizeof(last) - 1);
            }
        }

        if (poll(fds, 2, -1) > 0) {
            if (fds[0].revents & (POLLHUP | POLLERR | POLLNVAL))
                break;
            if (fds[1].revents & POLLIN) {
                uint64_t exp;
                read(tfd, &exp, sizeof(exp));
            }
        }
    }

    close(tfd);
    return 0;
}
