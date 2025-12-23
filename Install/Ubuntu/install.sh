#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo do-release-upgrade -d

sudo apt install git curl btop wireguard vim -y

sudo apt install python3 python3-pip python3-venv \ 
        libfuse2t64 lld build-essential 7zip \
        docker.io docker-compose -y

# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

sudo snap install obsidian --classic
# or download appimage

# Change keyboard input
# Settings → Region & Language → Input Sources
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'de')]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space']"

# Display
# Settings → Displays → Scale
gsettings set org.gnome.desktop.interface scaling-factor 2

# fcitx5
sudo apt install fcitx5 fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-modules fcitx5-mozc -y

im-config -n fcitx5

mkdir -p ~/.config/autostart
cat > ~/.config/autostart/fcitx5.desktop << 'EOF'
[Desktop Entry]
Name=Fcitx 5
GenericName=Input Method
Comment=Start Input Method
Exec=fcitx5
Icon=fcitx
Terminal=false
Type=Application
Categories=System;Utility;
StartupNotify=false
X-GNOME-Autostart-Phase=Applications
X-GNOME-AutoRestart=false
X-GNOME-Autostart-Notify=false
X-KDE-autostart-after=panel
EOF


# SSH
sudo apt install openssh-server
sudo systemctl enable --now ssh


sudo passwd root


