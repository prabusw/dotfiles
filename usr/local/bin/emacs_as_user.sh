#!/bin/bash
# Use the current user from the environment variable
target_user="${USER:-$(whoami)}"
# Set environment variables to ensure Emacs uses the correct configuration
export HOME="/home/$target_user"
export USER="$target_user"
# Run Emacs as the specified user
exec doas -u "$target_user" emacs "$@"
