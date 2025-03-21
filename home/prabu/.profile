# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022


# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


# https://wiki.alpinelinux.org/wiki/Wayland
# if [ -z "$XDG_RUNTIME_DIR" ]; then
# 	XDG_RUNTIME_DIR="/tmp/user/$(id -u)"

# 	mkdir -pm 0700 "$XDG_RUNTIME_DIR"
# 	export XDG_RUNTIME_DIR
# fi
# above script replaced by mkrundir
# export XDG_RUNTIME_DIR=$(mkrundir)

# The following moved /usr/local/bin/SwayWM
# export XDG_SESSION_TYPE=wayland
# export XDG_CURRENT_DESKTOP=sway
# # export XDG_SESSION_DESKTOP=sway
# export MOZ_ENABLE_WAYLAND=1
# export WLR_NO_HARDWARE_CURSORS=1
# export WLR_RENDERER=gles2
# export WLR_BACKENDS=drm,libinput
# export LIBVA_DRIVER_NAME=iHD
# export MESA_LOADER_DRIVER_OVERRIDE=iris
# export __GLX_VENDOR_LIBRARY_NAME=mesa
# export LIBSEAT_BACKEND=seatd
# export WLR_LIBINPUT_NO_DEVICES=1
# export ADW_DISABLE_PORTAL=1
# export GTK_THEME=Nordic

# Automatically launch sway on tty1

# if [ "$(tty)" = "/dev/tty1" ]; then
#      exec dbus-run-session sway
# fi

# # if running bash
if [ -n "$BASH_VERSION" ]; then
   # include .bashrc if it exists
   if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
   fi
fi
