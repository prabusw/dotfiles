#!/usr/bin/env sh
# notify-send "    $(date +'%a %d')"
sway-notify "    $(date +'%A %F')"
date +'%A %F %H:%M:%S' | wl-copy
# sway-notify -i calendar "$(date "+%A %F")"
