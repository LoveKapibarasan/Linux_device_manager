#!/bin/bash

# 0. Basic
# username and password will be asked.
# sudo raspi-config


# Audio tools and nmtui are installed
## alsamixer
## nmtui

# 1. Install
sudo apt update -y 
sudo apt upgrade -y

sudo apt purge nano vim -y

## WM git firefox code explorer terminal editor
sudo apt install sway wl-clipboard \
    git git-lfs openssh-client \
    qutebrowser qt6-multimedia ffmpeg \
    code xwayland \
    pcmanfm \
    vim-gtk3 \
    zsh \
    v4l-utils
    -y

# Purge foot and install terminal 
sudo apt purge foot -y && sudo apt install xterm kitty -y

# 2. Fonts
sudo apt install fonts-noto-cjk fonts-noto-cjk-extra -y

# 3. Pihole
curl -sSL https://install.pi-hole.net | bash
# choose wlp3s0 interface
# choose cloudflare or google
# show everything for ETL
sudo apt install sqlite3 libsqlite3-dev tcpdump -y

# 4. fcitx5
sudo apt install fcitx5 fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-modules fcitx5-mozc -y
fcitx5-configtool

# 5. Dev tools
sudo apt install python3 python3-pip python3-venv -y
sudo apt install nodejs npm -y


sudo apt autoremove
