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

# HP Printer
sudo pacman -S cups hplip
sudo systemctl enable --now cups.service

# FortClient nordvpn
yay -S forticlient --noconfirm
yay -S nordvpn-bin --noconfirm
systemctl enable --now nordvpnd
nordvpn login --token "$token"
nordvpn connect "$country"
nordvpn set dns 127.0.0.1
nordvpn set dns off
nordvpn set autoconnect on

