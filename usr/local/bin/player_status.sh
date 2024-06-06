#!/bin/sh
# Initialize variables
f_paused=/tmp/player_paused
f_playing=/tmp/player_playing
# while true; do
if [[ -f $f_paused ]]; then
    echo "status|string|Paused"
    echo ""
elif [[ -f $f_playing ]]; then
    echo "status|string|Playing"
    echo ""
else
    echo "status|string|Other"
    echo ""
fi
# done

