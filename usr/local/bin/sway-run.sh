#!/bin/sh                                                                                                                
# https://man.sr.ht/~kennylevinsen/greetd/#using-sway-for-gtkgreet
# https://github.com/senabi/dotfiles/blob/main/.xinitrc
# https://github.com/robstumborg/dotfiles/blob/master/bin/startw
# https://www.reddit.com/r/swaywm/comments/skpcmo/method_for_starting_applications_on_startup_on/

# Session       
# XDG_CURRENT_DESKTOP=sway already part of arch sway startup script etc/sway/config.d/50-systemd-user.conf but not working
export XDG_SESSION_TYPE=wayland # xdg/systemd
export XDG_SESSION_DESKTOP=sway # systemd
export XDG_CURRENT_DESKTOP=sway # xdg-desktop-portal

# export DESKTOP_SESSION=sway

# Maintain Wayland related stuff for applications in seperate file so can be used by other Wayland Desktops
source /usr/local/bin/wayland_enablement.sh

# Ensure GTK4 applications follow gsettings in Sway config file https://wiki.archlinux.org/title/GTK#GTK_3_and_GTK4
export ADW_DISABLE_PORTAL=1
export GTK_THEME=Nordic
# https://github.com/emersion/xdg-desktop-portal-wlr/issues/39#issuecomment-638752975
# exec /usr/bin/sway -V > /tmp/$USER_sway.log 2>&1 $@
# If you use systemd and want sway output to go to the journal, use this
# instead of the `exec sway $@` above:
#
    exec systemd-cat --identifier=sway sway $@
#
