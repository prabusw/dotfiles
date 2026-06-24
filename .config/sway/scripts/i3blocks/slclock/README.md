# slclock — A minimal clock for status bars with click handling

Based on
[time.c](https://github.com/francma/dotfiles/blob/master/.config/sway/blocks/time.c)
by francma. Extended to support click handling for i3blocks.

This utility has been written with assistance from LLMs like Claude
and Gemini.

## Why CLICK_SCRIPT

i3blocks handles clicks by re-running the block command with
`$BLOCK_BUTTON` set. This works for `interval=N` blocks but not for
`interval=persist` — the command is never re-run.

Instead, i3blocks writes click data to the persistent process's
stdin. slclock reads this and executes `CLICK_SCRIPT`, bypassing the
normal i3blocks click model entirely. `SIGCHLD` set to `SIG_IGN` to
prevent zombie processes from click script children.

`CLICK_SCRIPT` requires a complete path — no environment variables
like `$HOME` or i3blocks internals like `$SCRIPT_DIR` are expanded, as
slclock executes the script directly without a shell.

## i3blocks

```ini
[calendar]
command=slclock
interval=persist
CLICK_SCRIPT=/home/prabu/.config/sway/scripts/i3blocks/calendar
```

## Build & Install

```sh
cc -O2 -o slclock slclock.c
doas install -m755 slclock /usr/local/bin/
```
