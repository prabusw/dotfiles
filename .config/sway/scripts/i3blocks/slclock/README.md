# slclock — A minimal clock for status bars

slclock is a single C file clock for status bars like i3blocks. No
dependencies beyond libc and the Linux kernel. It runs as a persistent
process and handles its own update timing.

This utility has been written with assistance from LLMs like
Claude and Gemini.

## Usage

```
slclock [FORMAT]
```

`FORMAT` is a strftime format string. Defaults to `%H:%M:%S`.

## i3blocks

```ini
[calendar]
command=slclock "%H:%M"
interval=persist
```

## How it works

The update interval is derived from the format string automatically:

| Format contains | Update interval |
|---|---|
| `%S`, `%T` | 1 second |
| `%M`, `%R` | 60 seconds |
| `%H`, `%I` | 3600 seconds |
| date-only | 86400 seconds |

Updates are wall-clock aligned — a `%H:%M` format wakes at `:00`
every minute, not at a fixed offset from when the program started.

Uses `timerfd` with `CLOCK_REALTIME` and an absolute deadline. When
the system wakes from sleep, the kernel fires the timer immediately if
the boundary was already missed — no external signal or hook required.

Output is deduplicated — nothing is printed if the formatted time
hasn't changed.

## Build

```sh
cc -O2 -o slclock slclock.c
```
