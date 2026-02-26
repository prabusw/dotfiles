#!/bin/sh
playerctl -a status 2>/dev/null | grep -q "Playing" && exit 1 || exit 0
