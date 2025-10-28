#!/bin/bash

source ../util.sh
root_check

USER_HOME=$(get_user_home)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Git
touch "${USER_HOME}/.gitignore_global"
echo "*.swp" >> "${USER_HOME}/.gitignore_global"
echo "*.swo" >>  "${USER_HOME}/.gitignore_global"
git config --global core.excludesfile "${USER_HOME}/.gitignore_global"

# ZSH
chsh -s $(which zsh)
cp config/.zprofile "$USER_HOME/.zprofile"
cp config/.zshrc "$USER_HOME/.zshrc"


# fcitx 5
# 1. /etc/environment
sudo cp config/environment /etc/environment
cp config/profile "${USER_HOME}/.config/fcitx5/"

# Vim
echo 'set clipboard=unnamedplus' > ~/.vimrc
## Neovim
read -p "Enter your username: " username
git clone -o upstream git@github.com:neovim/neovim.git "${USER_HOME}/neovim"
cp config/init.lua "$USER_HOME/.config/nvim/init.lua"
chown "${username}" "$USER_HOME/.config/nvim/init.lua"

cd "${USER_HOME}/neovim"
make CMAKE_BUILD_TYPE=Release
sudo make install
git clone git@github.com:folke/lazy.nvim.git "${USER_HOME}/.local/share/nvim/lazy/lazy.nvim"
read -p  "Enter your username for nvim repository ownership: " username
chown -R "${username}:${username}" "/home/${username}/.local/share/nvim"
chown -R "${username}:${username}"  "/home/${username}/neovim"
mkdir -p "${USER_HOME}/.config/nvim"

origin_to_upstream "${USER_HOME}/.local/share/"

cd -

# WM
cp "${SCRIPT_DIR}/config/hyprland.conf" "${USER_HOME}/.config/hypr/hyprland.conf"
cp "${SCRIPT_DIR}/config/config" "${USER_HOME}/.config/sway/config"


# SearxNG
# https://docs.searxng.org/admin/installation-searxng.html#create-user
cp "${SCRIPT_DIR}/config/searxng.service" /etc/systemd/system/searxng.service
sudo systemctl enable searxng

# qutebrowser
## $BROWSER
echo 'export BROWSER=qutebrowser' >> "${USER_HOME}/.zshrc"
cp config/config.py "$USER_HOME/.config/qutebrowser/config.py"
cp config/qutebrowser.desktop "${USER_HOME}/.local/share/applications/qutebrowser.desktop"
cd "${USER_HOME}"
git clone -o upstream git@github.com:qutebrowser/qutebrowser.git "${USER_HOME}/qutebrowser"
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

# Symbolic Link
sudo rm /usr/bin/qutebrowser
sudo ln -s "${USER_HOME}/qutebrowser/.venv/bin/qutebrowser" /usr/bin/qutebrowser

cd -
# FortVPN
echo "openfortivpn"
read -p "Username: " username
echo
read -p "Password: " password
echo
mkdir -p /etc/openfortivpn
cat <<EOF | sudo tee -a /etc/openfortivpn/config > /dev/null
host = sslvpn.oth-regensburg.de
port = 443
realm = vpn-default
trusted-cert = 364fb4fa107e591626b3919f0e7f8169e9d2097974f3e3d55e56c7c756a1f94a
username = $username
password = $password
EOF

# Zathura
mkdir -p ~/.config/zathura   
echo "set selection-clipboard clipboard" >> "${USER_HOME}/.config/zathura/zathurarc"  



# Ollama
curl -fsSL https://ollama.com/install.sh | sh


# Alacritty
mkdir -p "${USER_HOME}/.config/alacritty/" 
cp config/alacritty.toml "${USER_HOME}/.config/alacritty/alacritty.toml"
