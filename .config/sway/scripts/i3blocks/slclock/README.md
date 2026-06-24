# slclock — A minimal clock for status bars

A single C file clock for i3blocks. No dependencies beyond libc and
the Linux kernel.

Based on [time.c](https://github.com/francma/dotfiles/blob/master/.config/sway/blocks/time.c)
by francma. Renamed to slclock to avoid conflict with utilities having similar name. Removed `now.tv_sec += 1` based on suggestion from Claude.

## Build

```sh
cc -O2 -o slclock slclock.c
```

## i3blocks

Copy the above binary to $PATH, so slclock can be called without
specifiying the path.

```ini
[calendar]
command=slclock
interval=persist
```
