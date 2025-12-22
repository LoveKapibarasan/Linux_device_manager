#!/bin/bash
source ../../util.sh

non_root_check

git lfs install

read -p "Enter username: " username
echo
read -p "Enter email: " email
echo

# Fix ownership of all files in .ssh directory
sudo chown user:user /home/user/.ssh/*

# Set correct permissions for the private key (must be readable only by you)
chmod 600 /home/user/.ssh/id_ed25519

# Set correct permissions for the public key (if it exists)
chmod 644 /home/user/.ssh/id_ed25519.pub

# Optional: Set correct permissions for the .ssh directory itself
chmod 700 /home/user/.ssh

cd 

git config --global user.name ""$username""
git config --global user.email ""$email""
git config --global pull.rebase false
# Line Change
git config --global core.autocrlf input
git config --list

# Repository List
USER_HOME=$(get_user_home)

# Arch Linux
# https://archlinux.org/

# tsshogi
git clone -o upstream git@github.com:sunfish-shogi/tsshogi.git "${USER_HOME}/tsshogi"

# Neo Vim
git clone -o upstream git@github.com:neovim/neovim.git "${USER_HOME}/neovim"
git clone -o upstream git@github.com:folke/lazy.nvim.git "${USER_HOME}/.local/share/nvim/lazy/lazy.nvim"

# Terminal 
git clone -o upstream git@github.com:alacritty/alacritty.git "${USER_HOME}/kitty"

# Qutebrowser
git clone -o upstream git@github.com:qutebrowser/qutebrowser.git "${USER_HOME}/qutebrowser"

# Hyprland
git clone -o upstream git@github.com:hyprwm/Hyprland.git "${USER_HOME}/Hyprland"

# Pi-hole
git clone -o upstream git@github.com:pi-hole/pi-hole.git "${USER_HOME}/pi-hole"
# git@github.com:pi-hole/FTL.git, git@github.com:pi-hole/web.git, git@github.com:pi-hole/docs.git

# fcitx 5 
git clone -o upstream git@github.com:fcitx/fcitx5.git "${USER_HOME}/fcitx5"
## Mozc  
git clone -o upstream git@github.com:google/mozc.git "${USER_HOME}/mozc"

# btop
git clone -o upstream git@github.com:aristocratos/btop.git  "${USER_HOME}/btop"

# LLM
git clone git@github.com:ollama/ollama.git "${USER_HOME}/ollama"

# Zsh
# https://zsh.sourceforge.io/

# Mail Server
git clone -o upstream git@github.com:mail-in-a-box/mailinabox.git "${USER_HOME}/mailinabox"

# Shogi-Extend
## Under src/ 
git clone -o upstream git@github.com:akicho8/shogi-extend.git "${USER_HOME}/src/shogi-extend"
## ImageMagick is reuired
sudo apt install -y \
  imagemagick \
  libmagickwand-dev
rm config/credentials.yml.enc config/master.key
EDITOR=vim bin/rails credentials:edit
