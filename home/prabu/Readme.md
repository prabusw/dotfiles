Approach1

Local Bare Repositories
1. Personal Dotfiles
git init --bare $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME/ config --local status.showUntrackedFiles no
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME/'
config add .vimrc
config commit -m "Add vimrc"
config add .bashrc
config commit -m "Add bashrc"
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME/ remote add origin git@github.com:prabusw/dotfiles.git
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME/ remote add origin https://github.com/prabusw/dotfiles.git
2. System Files
Initialize a bare repository for your system files:
git init --bare $HOME/.systemconf
alias sysconfig='git --git-dir=$HOME/.systemconf/ --work-tree=/'
Add your system configuration files:
sudo sysconfig add /etc/some-config-file
sudo sysconfig commit -m "Add some config file"
sudo sysconfig add /usr/local/bin/your_script
sudo sysconfig commit -m "Add script to /usr/local/bin"
git --git-dir=$HOME/.systemconf/ --work-tree=/ remote add origin https://github.com/prabusw/dotfiles.git
sysconfig remote add system git@github.com:prabusw/systemfiles.git
sysconfig push system master

Approach2:

The below approach works for most use cases. Only for deleting in
system folders, sudo needs to be used with full command.

prabu@homepc2 ~> git init --bare $HOME/.systemfiles
prabu@homepc2 ~> alias sysconfig='git --git-dir=$HOME/.systemfiles --work-tree=/'
prabu@homepc2 ~> sysconfig add /etc/btrbk/btrbk.conf
prabu@homepc2 ~> sysconfig add Readme.md
prabu@homepc2 ~> sudo git --git-dir=/home/prabu/.systemfiles --work-tree=/ rm /usr/local/bin/current_song.sh~
prabu@homepc2 ~> sysconfig status
prabu@homepc2 ~> sysconfig commit -m "added Readme.md"
prabu@homepc2 ~> sysconfig push origin master

prabu@homepc2 ~> systemctl list-units --state=running | grep -v systemd | awk '{print $1}' | grep service
dbus-broker.service
greetd.service
iwd.service
polkit.service
rpc-statd.service
rpcbind.service
rtkit-daemon.service
seatd.service
sshd.service
upower.service
user@1000.service

prabu@homepc2 ~> systemctl --user list-units --state=running | grep -v systemd | awk '{print $1}' | grep service
at-spi-dbus-bus.service
dbus-:1.26-org.a11y.atspi.Registry@0.service
dbus-broker.service
dconf.service
gvfs-daemon.service
pipewire-pulse.service
pipewire.service
wireplumber.service
xdg-desktop-portal.service
xdg-document-portal.service
xdg-permission-store.service
