alias glibc='LANG=en_US.UTF-8 bwrap --bind /var/chroots/debian / --dev-bind /dev /dev --proc /proc --bind /sys /sys --bind /run /run --bind /home /home --ro-bind /etc/resolv.conf /etc/resolv.conf --ro-bind /etc/passwd /etc/passwd --ro-bind /etc/group /etc/group'
alias sysconfig='git --git-dir=/home/prabu/.machine-config --work-tree=/'
alias dotfiles='git --git-dir=/home/prabu/.dotfiles --work-tree=/home/prabu'
