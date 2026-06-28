CC = cc
CFLAGS = -O2
PREFIX = $(HOME)/.local

slclock: slclock.c

install: slclock
	install -m755 slclock $(PREFIX)/bin/slclock

uninstall:
	rm -f $(PREFIX)/bin/slclock

clean:
	rm -f slclock

.PHONY: install uninstall clean
