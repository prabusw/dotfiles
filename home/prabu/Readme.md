my-dotfiles/
├── home/
│   ├── .vimrc
│   ├── .bashrc
│   └── ... (other personal dotfiles)
└── system/
    ├── etc/
    │   ├── some-config-file
    │   └── ... (other system config files)
    └── usr/
        └── local/
            └── bin/
                ├── your_script
                └── ... (other scripts)

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
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME/
prabu@homepc2 ~> alias sysconfig='git --git-dir=$HOME/.systemfiles --work-tree=/'
prabu@homepc2 ~> sysconfig add /etc/btrbk/btrbk.conf
prabu@homepc2 ~> sysconfig add Readme.md
prabu@homepc2 ~> sysconfig status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   Readme.md

Untracked files not listed (use -u option to show untracked files)
prabu@homepc2 ~> sysconfig push origin master
Everything up-to-date
prabu@homepc2 ~> sysconfig commit -m "added Readme.md"
[master 67ca35e] added Readme.md
 1 file changed, 41 insertions(+)
 create mode 100644 home/prabu/Readme.md
prabu@homepc2 ~> sysconfig push origin master
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 4 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (5/5), 1003 bytes | 1003.00 KiB/s, done.
Total 5 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To github.com:prabusw/dotfiles.git
   caa1e88..67ca35e  master -> master
