#!/usr/bin/bash
# Initialize variables
f_paused=/tmp/player_paused
f_playing=/tmp/player_playing
prev_player_status=""

# Check player status
player_status=$(playerctl status 2>/dev/null)


if [ -z "$player_status" ]; then
    # Handle the case when no players are found by checking if the player_status variable is empty or null
    [[ -f $f_paused ]] && rm -f $f_paused
    [[ -f $f_playing ]] && rm -f $f_playing

else
    # Player status has changed
    playerctl play-pause
    player_status=$(playerctl status 2>/dev/null)

    if [ "$player_status" == "Paused" ]; then
        [[ ! -f $f_paused ]] && touch $f_paused
        rm -f $f_playing
    elif [ "$player_status" == "Playing" ]; then
        [[ ! -f $f_playing ]] && touch $f_playing
        rm -f $f_paused
    elif [ "$player_status" == "Stopped" ]; then
        [[ ! -f $f_playing ]] && touch $f_playing
        rm -f $f_paused    
    fi
fi

