#!/usr/bin/env bash

# 0. 
# Wifi
# keyboard
# username, password
# hostname
# localization settings
## Country
## Timezone
sudo raspi-config

# 1. Install
sudo apt update & sudo apt upgrade
sudo apt purge nano
sudo apt autoremove
sudo apt install sway git git-lfs firefox zsh code pcmanfm vim xwayland -y
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
sudo apt install fonts-noto-cjk fonts-noto-cjk-extra
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/config

# 3. Pihole
curl -sSL https://install.pi-hole.net | bash


# 4. fcitx5
sudo apt install fcitx5 fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-mozc
fcitx5-configtool

## 1. /etc/environment
## 2. ~/.zprofile

# 5. Dev tools
sudo apt install -y python3 python3-pip python3-venv
sudo apt install -y nodejs npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# 6. NordVPN FortClient
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER
nordvpn login --token <token>
sudo systemctl unmask nordvpnd
sudo systemctl enable nordvpnd
sudo systemctl start nordvpnd
nordvpn set autoconnect on

sudo apt install openfortivpn -y
sudo sh -c 'cat >> /etc/openfortivpn/config <<EOF
host = sslvpn.oth-regensburg.de
port = 443
realm = vpn-default
trusted-cert = 364fb4fa107e591626b3919f0e7f8169e9d2097974f3e3d55e56c7c756a1f94a
username = abc12345
password = meinpasswort
EOF'


# 7. Graphics
sudo apt install -y mesa-utils mesa-vulkan-drivers vulkan-tools

# 8 Others
sudo apt install -y chromium