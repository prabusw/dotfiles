#!/usr/bin/bash
# https://sburris.xyz/posts/swaybar-configuration/
# https://www.nerdfonts.com/cheat-sheet
# Additional help sought and obtained from chatgptV3.5
# https://www.reddit.com/r/swaywm/comments/19b2wg8/arch_update_notification_for_sway_bar/

# Initialize variables
prev_player_status=""
prev_mute_status=""
FILE=/tmp/update_notification

while true; do
    # time=$(date +'%H:%M %a %d')
    time=$(date +'%H:%M')

    # Check for Arch updates by checking the presence of $FILE
    if [[ -f $FILE ]]; then    
        update="\\uf303"
    else
        update=""
    fi   

    # Check player status
    player_status=$(playerctl status 2>/dev/null)

    if [ "$player_status" != "$prev_player_status" ]; then
        # Player status has changed
        prev_player_status="$player_status"
        if [ "$player_status" == "Paused" ]; then
            pause="\\uf04c"
        else
            pause=""
        fi
    fi

    # Check volume mute status
    mute_status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if($3 == "[MUTED]") print "muted";}')

    if [ "$mute_status" != "$prev_mute_status" ]; then
        # Mute status has changed
        prev_mute_status="$mute_status"
        if [ "$mute_status" == "muted" ]; then
            mute="\\ueb24"
        else
            mute=""
        fi
    fi

     # Display status
    status_text="$update $pause $mute $time "
    echo -e "$status_text"
        
    # Introduce a delay before the next iteration
    sleep 1
done
