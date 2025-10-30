#!/bin/bash

# add code repo

sudo apt update -y && sudo apt upgrade -y

sudo apt install git git-lfs vim-gtk3 curl zsh btop -y

sudo apt install python3 python3-pip python3-venv \ 
npm \ 
clang libfuse2 lld build-essential 7zip -y


# pihole
curl -sSL https://install.pi-hole.net | bash

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


sudo passwd root