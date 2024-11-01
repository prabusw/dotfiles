#!/usr/bin/env sh

# Initialize variables
prev_mute_status=""

# Check volume mute status
mute_status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if($3 == "[MUTED]") print "muted";}')

if [ "$mute_status" != "$prev_mute_status" ]; then
    # Mute status has changed
    prev_mute_status="$mute_status"
    if [ "$mute_status" == "muted" ]; then
        mute="\\ueb24"
    else
        # mute="<U+F028>"
        mute=""""
    fi
fi

# Display status
echo -e "$mute"
