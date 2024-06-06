#!/bin/bash
# Check for Arch updates. Depending on the result either update or clear the file /tmp/update_notification
# This script is called by system service named update-check.service
# The /tmp/update_notification file is checked and sway-bar be updated accordingly by /usr/local/bin/sway_bar.sh
FILE=/tmp/update_nofitication

if [[ $(checkupdates) > 0 ]]
then
    [[ ! -f $FILE ]] && touch $FILE
else
    rm -f $FILE
fi
