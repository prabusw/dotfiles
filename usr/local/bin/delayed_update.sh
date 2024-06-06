#!/bin/bash
function show_update_notification() {
    local message="$1"

    # Send notification with buttons
    # notify-send -u critical "Updates Available" "$message" -i "dialog-information" -a apply -a cancel
    notify-send -u critical "Updates Available" "$message" -i "info" -a apply -a cancel

    # Wait for user response
    local response=$(zenity --question --text="Click on a button to proceed." --ok-label="Apply" --cancel-label="Cancel")

    if [ "$?" = "0" ]; then
        echo "apply"
    else
        echo "cancel"
    fi
}

# Check if updates are already downloaded and older than one week
if [[ -f /tmp/delayed_update_pending ]] && [[ $(find /tmp/delayed_update_pending -mtime +7) ]]; then
    # Before applying updates, prompt for confirmation
    response=$(show_update_notification "Important updates are ready to be applied.") # Capture exit status of function
    
    if [[ "$response" == "apply" ]]; then  # Apply button clicked
        pacman -Su
        rm /tmp/delayed_update_pending
        logger "Updates applied."
    else
        logger "Updates cancelled."
    fi

# Check for missing flag file
elif [[ ! -f /tmp/delayed_update_pending ]]; then
    logger "No pending updates available. Downloading updates."
    pacman -Syuw
    logger "Updates downloaded."
    touch /tmp/delayed_update_pending
fi

# # Check for missing flag file
# # Example usage
# result=$(show_update_notification "New updates are available. Do you want to apply them?")
# echo "User selected: $result"
