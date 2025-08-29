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
chmod 700 ~/.ssh              # ディレクトリは自分だけアクセス
chmod 600 ~/.ssh/id_rsa       # 秘密鍵は自分だけ読める
chmod 644 ~/.ssh/id_rsa.pub   # 公開鍵は誰でも読めてOK

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
## 3. ~/.config/sway/config

# 5. Dev tools
sudo apt install -y python3 python3-pip python3-venv
