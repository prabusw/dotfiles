# slclock — A clock for status bar based on suckless principles

slclock provides a clock for status bars like i3blocks based on
suckless principles. It is a single C file, no dependencies beyond
libc. It runs as a persistent process and handles its own update
timing. This utility has been written with assistance from LLMs like
Claude and Gemini.

## Motivation

The most common pattern seen in i3blocks, polybar, and similar bars is
to run a shell script loop to update the time. Basically, the Bar
forks a new shell process, the shell forks again to exec date
command. The date command runs, prints, exits and Shell exits and
finally the Bar collects output.

Waybar has a built-in clock module that handles time display
natively. It cannot be used outside waybar.

slstatus does include a clock, but it uses a single global interval
for everything and doesn't play well with i3blocks.

slclock fills this niche. It provides a clock that works as a drop-in
for any status bar that supports persistent commands or custom
modules.

## Comparison

Comparison Table
|    |Shell script|	Waybar clock|	slclock|
|Process per tick|	2 (fork+exec)|	0|	0|
|CPU per tick|	~2ms|	~5µs|	~5µs|
|Interval awareness	|No (bar-driven)|	Yes|	Yes|
|Wall-clock alignment|	No|	Yes|	Yes|
|Output deduplication|	No|	Yes|	Yes|
|Click handling|	External|	Built-in|	Built-in|
|Dependencies|	sh, coreutils|	GTK, C++ runtime...| libc only|
|Binary size|	N/A|	~2MB+|	~20KB|
|Composable|	Limited|	No|	Yes|
|Bar agnostic|	Yes|	No|	Yes|

## Technical overview

The update interval is derived from the format string itself. A %H:%M
format has no reason to wake every second — it cannot change more
often than once per minute. A date-only format can sleep for a full
day. slclock figures this out automatically.

### Wall-clock alignment

Rather than sleeping for a fixed duration from whenever it last ran,
slclock sleeps until the next boundary:

For a %H:%M format, it wakes at :00 every minute — exactly when the
display can change — not at :23 or :47 depending on when the program
started.

If the formatted time hasn't changed, nothing is printed. The bar
receives no unnecessary updates.

### Non-blocking click handling

Click events from i3blocks arrive on stdin. slclock handles them
inside the same poll() call that manages sleep — no extra threads, no
extra processes sitting idle. When a click fires, it forks once to run
the click script and immediately returns to waiting. SIGCHLD is set to
SIG_IGN so the kernel reaps children automatically — no zombie
processes.

### Graceful shutdown

SIGTERM, SIGINT, and SIGHUP all set a flag that exits the main loop
cleanly. POLLHUP on stdin detects when the parent bar has died and
exits without needing a signal at all.

slclock does one thing: display the time efficiently. It does not
manage layouts, themes, or modules. It does not know about D-Bus or
Wayland protocols. It reads a format string, sleeps until the output
could change, and prints when it does.

### Composability

What triggers a refresh, what happens on suspend resume, what the
click script does — are handled outside the program by composing
simple tools together. A two-line swayidle resume hook signals
i3blocks, which signals slclock. Each piece remains simple and
replaceable.

'
## Usage with i3blocks

```
[calendar]
command=slclock "%H:%M" "" --action
interval=persist
CLICK_SCRIPT=~/.config/sway/scripts/calendar
signal=4
```
