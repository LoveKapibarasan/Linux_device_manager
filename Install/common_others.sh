#!/bin/bash

source "${SCRIPT_DIR}/../util.sh"
root_check

USER_HOME=$(get_user_home)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"


# Config
cp "${SCRIPT_DIR}/.config" "$USER_HOME"
cp "${SCRIPT_DIR}/usr" /usr
cp "${SCRIPT_DIR}/etc" /etc/environment

# Change Origin
origin_to_upstream "${USER_HOME}/.cache"
origin_to_upstream "${USER_HOME}/.local/share/"

# Service
sudo systemctl enable searxng

# Git
touch "${USER_HOME}/.gitignore_global"
echo "*.swp" >> "${USER_HOME}/.gitignore_global"
echo "*.swo" >>  "${USER_HOME}/.gitignore_global"
git config --global core.excludesfile "${USER_HOME}/.gitignore_global"

# ZSH
chsh -s $(which zsh)
cp "${SCRIPT_DIR}/.config/.zprofile" "$USER_HOME/.zprofile"
cp "${SCRIPT_DIR}/.config/.zshrc" "$USER_HOME/.zshrc"


# Neovim
read -p "Enter your username: " username
git clone -o upstream git@github.com:neovim/neovim.git "${USER_HOME}/neovim"
chown "${username}" "$USER_HOME/.config/nvim/init.lua"

cd "${USER_HOME}/neovim"
make CMAKE_BUILD_TYPE=Release
sudo make install
git clone -o upstream git@github.com:folke/lazy.nvim.git "${USER_HOME}/.local/share/nvim/lazy/lazy.nvim"
read -p  "Enter your username for nvim repository ownership: " username
chown -R "${username}:${username}" "/home/${username}/.local/share/nvim"
chown -R "${username}:${username}"  "/home/${username}/neovim"
mkdir -p "${USER_HOME}/.config/nvim"

# Alacritty
mkdir -p "${USER_HOME}/.config/alacritty/themes"
git clone -o upstream https://github.com/alacritty/alacritty-theme "${USER_HOME}/.config/alacritty/themes"
cd -

# SearxNG
# https://docs.searxng.org/admin/installation-searxng.html


# qutebrowser
# https://qutebrowser.org/doc/install.html#tox
cd "${USER_HOME}" && git clone -o upstream git@github.com:qutebrowser/qutebrowser.git "${USER_HOME}/qutebrowser"

# Symbolic Link
sudo rm /usr/bin/qutebrowser
sudo ln -s "${USER_HOME}/qutebrowser/.venv/bin/qutebrowser" /usr/bin/qutebrowser

# Zathura
mkdir -p ~/.config/zathura   
echo "set selection-clipboard clipboard" >> "${USER_HOME}/.config/zathura/zathurarc"  

# Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pihole
curl -sSL https://install.pi-hole.net | sudo bash