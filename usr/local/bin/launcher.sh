#!/bin/bash

# # Use slurp to select a region
# region=$(slurp)

# # Get the geometry (x, y, width, height) of the selected region
# read -r x y w h <<< "$(echo "$region" | jq -r '.x, .y, .width, .height')"

# # Use grim to capture the selected region
# grim -g "$w"x"$h"+"$x"+"$y" ~/screenshot.png

# Use jq to parse the application list (customize as needed)
# applications=$(cat applications.json | jq -r '.[]')
applications=$(find /usr/bin /bin -type f -executable | grep -E "/(usr|bin)/[^/]+$" | sed 's#.*/##')



# Use fzf for terminal-based selection
chosen=$(echo "$applications" | fzf)

# Run the chosen application directly
eval "$chosen"

