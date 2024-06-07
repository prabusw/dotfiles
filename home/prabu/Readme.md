# Sway dotfiles using Nord theme

Dotfiles related to all the tools listed below can be found in this repository. Most of them have been are based on online resources and sources are cited in most cases.

## Sway configuration Details
Sway configuration uses the following tools
* foot - terminal
* mako - notification daemon
* greetd - login manager
* nwg-hello -greeter for the greetd
* swaylock - locking tool
* i3blocks - feed generator for swaybar
* tofi - dynamic menu
* swappy - screenshot editing tool
* wlogout - logout menu
* Nord - Theme

### Other Tools used
* btrfs filesystem 
* refind - boot manager
* btrbk - Backup tool for managing snapshots
* snapper - snapshot creator

## Tracking swaywm dotfiles using a bare git repository 
To track changes to config files and saving them for future needs(restoration) git is commonly used. By keeping the dotfiles in github or similar online hosting providers, one can share the configuration with others.

The only tool used here is git. Normal user account is used for adding files as long as the user has Read permission. Only for deleting files added from system folders and when the default user does not have Read permission, sudo needs to be used with full command.


The below steps will suffice to keep track of dotfiles for single desktop. For detailed explanation refer to the sources

```
prabu@homepc2 ~> git init --bare $HOME/.systemfiles
prabu@homepc2 ~> alias sysconfig='git --git-dir=$HOME/.systemfiles --work-tree=/'
prabu@homepc2 ~> echo "alias sysconfig='git --git-dir=/home/prabu/.systemfiles --work-tree=/'" >> ~/.config/fish/config.fish
prabu@homepc2 ~> source ~/.config/fish/config.fish
prabu@homepc2 ~> sysconfig add /etc/btrbk/btrbk.conf
prabu@homepc2 ~> sysconfig add Readme.md
prabu@homepc2 ~> sudo git --git-dir=/home/prabu/.systemfiles --work-tree=/ rm /usr/local/bin/current_song.sh~
prabu@homepc2 ~> sysconfig status
prabu@homepc2 ~> sysconfig commit -m "added Readme.md"
prabu@homepc2 ~> sysconfig push origin master
```
## Information on current system status
### View the currently running user systemd services 
```
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
```
### View the currently running systemd services 
```
prabu@homepc2 ~> systemctl list-units --state=running | grep -v systemd | awk '{print $1}' | grep service
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
```
Sources:
https://news.ycombinator.com/item?id=11071754
https://www.atlassian.com/git/tutorials/dotfiles

