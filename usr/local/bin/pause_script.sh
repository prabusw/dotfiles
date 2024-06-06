#!/usr/bin/bash
# Initialize variables
FILE=/tmp/player_paused
 # Check player status

playerctl play-pause
player_status=$(playerctl status 2>/dev/null)

if [ "$player_status" != "$prev_player_status" ]; then
    # Player status has changed
    prev_player_status="$player_status"
    if [ "$player_status" == "Paused" ]; then
        [[ ! -f $FILE ]] && touch $FILE
    else
        rm -f $FILE
    fi
fi
