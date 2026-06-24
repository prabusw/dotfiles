# slclock — A clock for status bars based on suckless principles

slclock provides a clock for status bars like i3blocks based on
suckless principles. It is a single C file, no dependencies beyond
libc. It runs as a persistent process and handles its own update
timing.

This utility has been written with assistance from LLMs like
Claude and Gemini.

## Motivation

The most common pattern seen in i3blocks, polybar, and similar bars is
to run a shell script loop to update the time. The bar forks a new
shell process, the shell forks again to exec the date command. The
date command runs, prints, exits and the shell exits and finally the
bar collects output.

Waybar has a built-in clock module that handles time display
natively. It cannot be used outside Waybar.

slstatus does include a clock, but it uses a single global interval
for everything and doesn't play well with i3blocks.

slclock fills this niche. It provides a clock that works as a drop-in
for any status bar that supports persistent commands or custom modules.

## Comparison

| | Shell script | Waybar clock | slclock |
|---|---|---|---|
| Process per tick | 2 (fork+exec) | 0 | 0 |
| CPU per tick | ~2ms | ~5µs | ~5µs |
| Interval awareness | No (bar-driven) | Yes | Yes |
| Wall-clock alignment | No | Yes | Yes |
| Output deduplication | No | Yes | Yes |
| Click handling | External | Built-in | Built-in |
| Dependencies | sh, coreutils | GTK, C++ runtime... | libc,linux kernel|
| Binary size | N/A | ~2MB+ | ~14KB |
| Composable | Limited | No | Yes |
| Bar agnostic | Yes | No | Yes |

## Usage

```
slclock [FORMAT] [LABEL] [CLICK_ARGS...]
```

### Arguments

| Argument | Description |
|---|---|
| `FORMAT` | strftime format string (default: `%H:%M:%S`) |
| `LABEL` | optional prefix text (default: empty) |
| `CLICK_ARGS` | arguments passed to `CLICK_SCRIPT` on mouse events |

### Environment variables

| Variable | Description |
|---|---|
| `DATEFMT` | time format, used if FORMAT not provided |
| `LABEL` | prefix label, used if LABEL not provided via CLI |
| `CLICK_SCRIPT` | script to execute on click events |

Priority: CLI arguments > Environment variables > Defaults

### Format specifiers

Common strftime formats:

| Specifier | Description |
|---|---|
| `%H` | Hour (00-23) |
| `%M` | Minute (00-59) |
| `%I` | Hour (01-12) |
| `%S` | Second (00-59) |
| `%p` | AM/PM |
| `%A` | Weekday name |
| `%Y` | Year (4-digit) |
| `%m` | Month (01-12) |
| `%d` | Day of month (01-31) |
| `%B` | Month name |
| `%T` | Time (%H:%M:%S) |
| `%R` | Time (%H:%M) |

## Technical overview

The update interval is derived from the format string itself. A `%H:%M`
format has no reason to wake every second — it cannot change more
often than once per minute. A date-only format can sleep for a full
day. slclock figures this out automatically.

| Format contains | Update interval |
|---|---|
| `%S`, `%T` | every 1 second |
| `%M`, `%R` | every 60 seconds |
| `%H`, `%I` | every 3600 seconds |
| date-only | every 86400 seconds |

### Wall-clock alignment

Rather than sleeping for a fixed duration from whenever it last ran,
slclock sleeps until the next boundary. For a `%H:%M` format, it wakes
at `:00` every minute — exactly when the display can change — not at
`:23` or `:47` depending on when the program started.

If the formatted time hasn't changed, nothing is printed. The bar
receives no unnecessary updates.

### Resume from sleep

slclock uses `timerfd` with `CLOCK_REALTIME` and an absolute deadline.
When the system wakes from sleep, the kernel sees the timer boundary
was already passed and fires immediately — no external signal or
swayidle hook required.

### Non-blocking click handling

Click events from i3blocks arrive on stdin. slclock handles them
inside the same `poll()` call that manages the timer — no extra
threads, no extra processes sitting idle. When a click fires, it forks
once to run the click script and immediately returns to waiting.
`SIGCHLD` is set to `SIG_IGN` so the kernel reaps children
automatically — no zombie processes.

### Graceful shutdown

`SIGTERM`, `SIGINT`, and `SIGHUP` all set a flag that exits the main
loop cleanly. `POLLHUP` on stdin detects when the parent bar has died
and exits without needing a signal at all.

### Composability

What triggers a refresh, what happens on suspend resume, what the
click script does — these are handled outside the program by composing
simple tools together. Each piece remains simple and replaceable.

## i3blocks configuration

i3blocks needs complete path for the CLICK_SCRIPT.

```ini
[calendar]
command=slclock "%H:%M" "" --action
interval=persist
CLICK_SCRIPT=/home/prabu/.config/sway/scripts/i3blocks/calendar
```

## Build

```sh
cc -O2 -o slclock slclock.c
```
