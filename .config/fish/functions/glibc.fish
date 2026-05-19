function glibc
    set dbus_path (string replace 'unix:path=' '' (string split ',' $DBUS_SESSION_BUS_ADDRESS)[1])
    LANG=en_US.UTF-8 bwrap --bind /var/chroots/debian / --dev-bind /dev /dev --proc /proc --bind /sys /sys --bind /run /run --bind /home /home --bind "$XDG_RUNTIME_DIR" "$XDG_RUNTIME_DIR" --bind $dbus_path $dbus_path --ro-bind /etc/resolv.conf /etc/resolv.conf --ro-bind /etc/passwd /etc/passwd --ro-bind /etc/group /etc/group --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY" --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS" $argv
end
