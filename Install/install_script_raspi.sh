#!/bin/bash

# 0. 
# Wifi
# keyboard
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="de"/' /etc/default/keyboard
sudo setupcon
# username, password
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

# 1. Install
dpkg -l
sudo apt update & sudo apt upgrade
sudo apt purge nano dmenu vim vim-common vim-runtime vim-tiny -y

sudo apt autoremove
sudo apt install sway git git-lfs ssh-askpass firefox zsh code pcmanfm vim-gtk3 xwayland -y
git lfs install
git config --global user.name "<name>"
git config --global user.email "<email_address>"
chsh -s $(which zsh)

# chmod
chmod 700 ~/.ssh             
chmod 600 ~/.ssh/id_rsa      
chmod 644 ~/.ssh/id_rsa.pub  

## nmtui is installed.

# 2. Fonts
sudo apt install fonts-noto-cjk fonts-noto-cjk-extra -y
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/config

# 3. Pihole
curl -sSL https://install.pi-hole.net | bash


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
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
node -v
nvm install x 
nvm use x
