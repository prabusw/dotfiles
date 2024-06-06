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
