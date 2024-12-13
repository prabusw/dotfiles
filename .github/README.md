# Sway dotfiles using Nord theme

Dotfiles related to sway desktop and all the related tools listed
below can be found in this repository. Most of configuration is based
on online resources. Sources are cited in the individual files.

The dotfiles in this repository are used in a pc which dual boots
between Arch Linux and Alpine Linux. So any configuration related to
systemd is only for Arch Linux.

![ScreenShot](/home/prabu/Screenshots/2024-08-25_21-02-19.png )
## Sway configuration Details

Sway configuration uses the following tools
* foot - terminal
* mako - notification daemon
* greetd - login manager
* gtkgreet in Alpine and regreet in Arch - greeter
* swaylock - locking tool
* i3blocks - feed generator for swaybar
* tofi - dynamic menu
* swappy - screenshot editing tool
* wlogout - logout menu
* Nord - Theme
* seatd in alpine and elogind in arch

### Other Tools used
* btrfs filesystem
* refind - boot manager
* btrbk - Backup tool for managing snapshots
* snapper - snapshot creator
* emacs
* fish shell(ash is Alpine default)


## Tracking swaywm dotfiles using a bare git repository

The only tool used here is git. Normal user account is used for adding
files as long as the user has Read permission. Only for deleting files
added from system folders and when the default user does not have Read
permission, sudo needs to be used with full command.

The below steps will suffice to keep track of dotfiles for single
desktop. For detailed explanation refer to the sources

```
$ git init --bare $HOME/.systemfiles
$ alias sysconfig='git --git-dir=$HOME/.systemfiles --work-tree=/'
$ echo "alias sysconfig='git --git-dir=/home/prabu/.systemfiles --work-tree=/'" >> ~/.config/fish/config.fish
$ echo "alias sysconfig='git --git-dir=/home/prabu/.systemfiles --work-tree=/'" >> ~/.config/ash/ashrc
$ source ~/.config/fish/config.fish
$ sysconfig add /etc/btrbk/btrbk.conf
$ sysconfig add /.github/README.md
$ sudo git --git-dir=/home/prabu/.systemfiles --work-tree=/ rm /usr/local/bin/current_song.sh
$ sysconfig status
$ sysconfig commit -m "added Readme.md"
$ sysconfig push origin master
```
Sources:
* https://news.ycombinator.com/item?id=11071754
* https://www.atlassian.com/git/tutorials/dotfiles
