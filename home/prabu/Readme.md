# Sway dotfiles using Nord theme

## Tracking swaywm dotfiles using a bare git repository 
To track changes to config files and saving them for future needs(restoration) git is commonly used. By keeping the dotfiles in github or similar online hosting providers, one can share the configuration with others.

The only tool used here is git. Normal user account is used for adding files as long as the user has Read permission. Only for deleting files added from system folders and when the default user does not have Read permission, sudo needs to be used with full command.

Create a bare git directory
prabu@homepc2 ~> git init --bare $HOME/.systemfiles
prabu@homepc2 ~> alias sysconfig='git --git-dir=$HOME/.systemfiles --work-tree=/'
prabu@homepc2 ~> echo "alias sysconfig='git --git-dir=/home/prabu/.systemfiles --work-tree=/'" >> ~/.co
nfig/fish/config.fish
prabu@homepc2 ~> source ~/.config/fish/config.fish
prabu@homepc2 ~> sysconfig add /etc/btrbk/btrbk.conf
prabu@homepc2 ~> sysconfig add Readme.md
prabu@homepc2 ~> sudo git --git-dir=/home/prabu/.systemfiles --work-tree=/ rm /usr/local/bin/current_song.sh~
prabu@homepc2 ~> sysconfig status
prabu@homepc2 ~> sysconfig commit -m "added Readme.md"
prabu@homepc2 ~> sysconfig push origin master

### To view the currently running systemd services 
prabu@homepc2 ~> systemctl --user list-units --state=running | grep -v systemd | awk '{print $1}' | grep service
* at-spi-dbus-bus.service
* dbus-:1.26-org.a11y.atspi.Registry@0.service
* dbus-broker.service
* dconf.service
* gvfs-daemon.service
* pipewire-pulse.service
* pipewire.service
* wireplumber.service
* xdg-desktop-portal.service
* xdg-document-portal.service
* xdg-permission-store.service

### prabu@homepc2 ~> systemctl list-units --state=running | grep -v systemd | awk '{print $1}' | grep service
* dbus-broker.service
* greetd.service
* iwd.service
* polkit.service
* rpc-statd.service
* rpcbind.service
* rtkit-daemon.service
* seatd.service
* sshd.service
* upower.service
* user@1000.service

Source:https://news.ycombinator.com/item?id=11071754
https://www.atlassian.com/git/tutorials/dotfiles

