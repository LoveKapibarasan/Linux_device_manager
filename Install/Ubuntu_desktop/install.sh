#!/bin/bash

# add code repo

sudo apt update && sudo apt upgrade

sudo apt install git curl

# pihole
curl -sSL https://install.pi-hole.net | bash

# fcitx5
sudo apt install fcitx5 fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 fcitx5-modules fcitx5-mozc -y
fcitx5-configtool