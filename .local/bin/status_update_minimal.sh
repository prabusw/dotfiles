#!/bin/sh
# https://www.reddit.com/r/swaywm/comments/174jsze/ipc_response_use_in_swaybar_status_script/?rdt=59457
printf "{\"version\":1}\n"
printf "[\n"
while true
do
	printf "["
	printf "{\"full_text\":\"%s\"}," "$(makoctl list | jq -r '.data[0][0].summary.data | select(type == "string")')"
	# printf "{\"full_text\":\"%s\"}," "$(swaymsg -t get_inputs | jq -r '[.[] | select(.type == "keyboard")][0].xkb_active_layout_name')"
	# printf "{\"full_text\":\"%s\"}," "$(cat /sys/class/power_supply/BAT0/capacity)"
	# printf "{\"full_text\":\"%s\"}," "$(date +%c)"
    printf "{\"full_text\":\"%s\"}," "$(date +'%H:%M %a %d')"
	printf "],"
	timeout 1 swaymsg -t subscribe '["input","binding"]' >/dev/null
done
