#!/usr/bin/bash
# https://sburris.xyz/posts/swaybar-configuration/
# https://www.nerdfonts.com/cheat-sheet
# Additional help sought and obtained from chatgptV3.5
# https://www.reddit.com/r/swaywm/comments/19b2wg8/arch_update_notification_for_sway_bar/

# Initialize variables
prev_player_status=""
prev_mute_status=""
FILE=/tmp/update_notification

# Create a temporary swaybar configuration file
config_file="/tmp/swaybar_config"
cat <<EOF > "$config_file"
bar {
    id bar-0
    status_command custom-status-script.sh
}
EOF

# Start swaybar with the temporary configuration file
swaybar -c "$config_file" -s "$SWAYSOCK" &

# # Create a socket for communication with sway
# rm -f "$SWAYSOCK"
# swaybar -s "$SWAYSOCK" &

block_id="block1"  # Change this to a unique identifier for your block

while true; do
    time=$(date +'%H:%M %a %d')
    
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

    # Construct JSON string with double quotes and indentation
    swaybar_json='{
        "version": 1.0,
        "bar": "bar-0",
        "command": "update",
        "block": '$block_id',
        "content": [
            {
                "text": "'"$update"'",
                "align": "left"
            },
            {
                "text": "'"$pause"'",
                "align": "left"
            },
            {
                "text": "'"$mute"'",
                "align": "left"
            },
            {
                "text": "'"$time"'",
                "align": "center"
            }
        ]
    }'

    # Send JSON data to swaybar via the socket
    echo -e "$swaybar_json" > "$SWAYSOCK"

    # Introduce a delay before the next iteration
    sleep 1
done
