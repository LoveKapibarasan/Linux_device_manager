#!/bin/bash

# Fingerprint
sudo pacman -S fprintd
fprintd-enroll $USER -f right-index-finger

## Camera
sudo pacman -S cheese --noconfirm

# PostgreSQL
sudo pacman -S postgresql
## Initialize database cluster
sudo -iu postgres initdb -D /var/lib/postgres/data
sudo systemctl enable --now postgresql

# FortClient nordvpn
yay -S forticlient nordvpn-bin
yay -Rns nordvpn-bin

# Pyenv
yay -S pyenv pyenv-virtualenv  --noconfirm
