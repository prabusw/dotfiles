#!/bin/sh

# Check if we have exactly two arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file1> <file2>"
    exit 1
fi

# Determine the real user
real_user="${DOAS_USER:-$(whoami)}"

# Set XDG_RUNTIME_DIR dynamically
XDG_RUNTIME_DIR="/tmp/$(id -u "$real_user")-runtime-dir"

# Ensure the runtime directory exists and has correct permissions
mkdir -p "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

# Run Emacs with your custom configuration
doas env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    HOME="/home/$real_user" \
    USER="$real_user" \
    DISPLAY="$DISPLAY" \
    emacs --load "/home/$real_user/.emacs.d/init.el" \
    --eval "(progn 
              (require 'ediff)
              (ediff-files \"$1\" \"$2\"))"
