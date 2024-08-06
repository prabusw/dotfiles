#!/bin/sh
# Initialize variables
FILE=/tmp/player_paused
# while true; do
if [[ -f $FILE ]]; then
    echo "status|string|Paused"
    echo ""
else
    echo "status|string|Other"
    echo ""
fi
# done

