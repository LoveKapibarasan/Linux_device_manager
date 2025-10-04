#!/bin/bash

source ../util.sh
root_check

USER_HOME=$(get_user_home)

# ZSH
chsh -s $(which zsh)
cp config/.zprofile "$USER_HOME/.zprofile"
cp config/.zshrc "$USER_HOME/.zshrc"

# fcitx 5
# 1. /etc/environment
sudo cp config/environment /etc/environment

# Vim
echo 'set clipboard=unnamedplus' > ~/.vimrc
## Neovim
read -p "Enter your username: " username
git clone -o upstream https://github.com/neovim/neovim "${USER_HOME}/neovim"
cp config/init.lua "$USER_HOME/.config/nvim/init.lua"
chown "${username}" "$USER_HOME/.config/nvim/init.lua"

cd "${USER_HOME}/neovim"
make CMAKE_BUILD_TYPE=Release
sudo make install
git clone https://github.com/folke/lazy.nvim.git \
  "${USER_HOME}/.local/share/nvim/lazy/lazy.nvim"
read -p  "Enter your username for nvim repository ownership: " username
chown -R "${username}:${username}" "/home/${username}/.local/share/nvim"
chown -R "${username}:${username}"  "/home/${username}/neovim"
mkdir -p "${USER_HOME}/.config/nvim"

origin_to_upstream "${USER_HOME}/.local/share/"

cd -

# WM
cp config/hyprland.conf "$USER_HOME/.config/hypr/hyprland.conf"
cp config/config "$USER_HOME/.config/sway/config"


# qutebrowser
cp config/config.py "$USER_HOME/.config/qutebrowser/config.py"
cd "${USER_HOME}"
git clone -o upstream https://github.com/qutebrowser/qutebrowser.git "${USER_HOME}/qutebrowser"
cd "${USER_HOME}/qutebrowser"
cd qutebrowser

read -p "Can you use the newest pyqt? (y/N): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    python3 scripts/mkvenv.py
else
    read -p "Enter pyqt version: " version
    python3 scripts/mkvenv.py --pyqt-version "$version" # 6.7
     python3 scripts/mkvenv.py --pyqt-type link --pyqt-version 6 
     # Link with System PyQt6
# libtiff.so.n problems in RasberryPi
# sudo ln -sf /usr/lib/aarch64-linux-gnu/libwebp.so.7 /usr/lib/aarch64-linux-gnu/libwebp.so.6
# sudo ln -sf /usr/lib/aarch64-linux-gnu/libtiff.so.6 /usr/lib/aarch64-linux-gnu/libtiff.so.5
# sudo ldconfig

cd -
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

# Firefox
# cp config/profiles.ini "$USER_HOME/.mozilla/firefox/profiles.ini"
# rm -rf "$USER_HOME/.mozilla/firefox/"*.default-release
