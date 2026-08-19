function run-bwrap
    set root $argv[1]
    LANG=en_US.UTF-8 bwrap --bind $root / --dev-bind /dev /dev --proc /proc --bind /sys /sys \
        --bind /run /run --bind /tmp /tmp --bind /home /home \
        --ro-bind /etc/resolv.conf /etc/resolv.conf \
        --ro-bind /etc/passwd /etc/passwd --ro-bind /etc/group /etc/group \
        $argv[2..]
end
