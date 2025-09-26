#!/bin/bash

source ../util.sh
root_check

USER_HOME=$(get_user_home)

# ZSH
chsh -s $(which zsh)

# fcitx 5
# 1. /etc/environment
sudo bash -c 'cat >> /etc/environment << "EOF"
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
EOF'

# Vim
echo 'set clipboard=unnamedplus' > ~/.vimrc
## Neovim
git clone https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=Release
sudo make install

# .zsh
cp config/.zprofile "$USER_HOME/.zprofile"
cp config/.zshrc "$USER_HOME/.zshrc"

# WM
cp config/hyprland.conf "$USER_HOME/.config/hypr/hyprland.conf"
cp config/sway "$USER_HOME/.config/sway/config"

# FortVPN
echo "openfortivpn"
read -p "Username: " username
echo
read -p "Password: " password
echo

cat <<EOF | sudo tee -a /etc/openfortivpn/config > /dev/null
host = sslvpn.oth-regensburg.de
port = 443
realm = vpn-default
trusted-cert = 364fb4fa107e591626b3919f0e7f8169e9d2097974f3e3d55e56c7c756a1f94a
username = $username
password = $password
EOF