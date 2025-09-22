#!/bin/bash

# 0. Basic
# username, password
# Wifi 
## nmtui is installed
# keyboard
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="de"/' /etc/default/keyboard
sudo setupcon
## Check
localectl status
setxkbmap -query
cat /etc/default/keyboard


# hostname=pc
sudo hostnamectl set-hostname pc
# localization settings
sudo sed -i 's/^# *\(de_DE.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo sed -i 's/^# *\(ja_JP.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_GB.UTF-8
locale -a
## Country for Wifi
echo -e "[device]\nwifi.country=DE" | sudo tee /etc/NetworkManager/conf.d/wifi-country.conf
cat /etc/NetworkManager/conf.d/wifi-country.conf
sudo systemctl restart NetworkManager
sudo iw reg set DE
## Timezone
sudo timedatectl set-timezone Europe/Berlin
sudo raspi-config
# Audio tools are installed
## alsamixer

# 1. Install
dpkg -l
sudo apt update & sudo apt upgrade
## Delete nano vim 
sudo apt purge nano dmenu vim vim-common vim-runtime vim-tiny -y
sudo apt autoremove

## sway
sudo apt install sway -y

## git
sudo apt install git git-lfs openssh-client
git lfs install

## firefox
sudo apt install firefox -y 

## Code with xwayland
sudo apt install code xwayland -y

## Vim
sudo apt install vim-gtk3 -y

## pcmanfm
sudo apt install pcmanfm -y

## zsh
sudo apt install zsh -y
chsh -s $(which zsh)

## nmtui is installed.

# 2. Fonts
sudo apt install fonts-noto-cjk fonts-noto-cjk-extra -y

# 3. Pihole
curl -sSL https://install.pi-hole.net | bash
# choose wlp3s0 interface
# choose cloudflare or google
# show everything for ETL
# sudo setpassword
sudo apt install sqlite3 libsqlite3-dev -y

# 4. fcitx5
sudo apt install fcitx5 fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-modules fcitx5-mozc -y
fcitx5-configtool

## 4-1. /etc/environment
sudo bash -c 'cat >> /etc/environment << "EOF"
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
EOF'

## 4-2. ~/.zprofile

# 5. Dev tools
sudo apt install python3 python3-pip python3-venv -y
sudo apt install nodejs npm -y
