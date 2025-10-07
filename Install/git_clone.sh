#!/bin/bash
source ../../util.sh

non_root_check

git lfs install

read -p "Enter username: " username
echo
read -p "Enter email: " email
echo

cd 

git config --global user.name ""$username""
git config --global user.email ""$email""
git config --list

git clone git@github.com:LoveKapibarasan/Linux_device_manager.git
git clone git@github.com:LoveKapibarasan/utils_python.git
git clone git@github.com:LoveKapibarasan/kifs.git
git clone git@github.com:LoveKapibarasan/my_website.git
git clone git@github.com:LoveKapibarasan/enc-private.git

git clone git@github.com:LoveKapibarasan/shogihome.git
cd "${HOME}/shogihome"
git remote add upstream git@github.com:sunfish-shogi/shogihome.git
cd


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

