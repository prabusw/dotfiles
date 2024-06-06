#!/usr/bin/bash
# notify-send "    $(date +'%a %d')"
date +'%A %F %H:%M:%S' | wl-copy
sway-notify "    $(date +'%A %F')"
# sway-notify -i calendar "$(date "+%A %F")"
