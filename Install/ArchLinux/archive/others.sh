#!/bin/bash

# Fingerprint
sudo pacman -S fprintd
fprintd-enroll $USER -f right-index-finger


# PostgreSQL
sudo pacman -S postgresql
## Initialize database cluster
sudo -iu postgres initdb -D /var/lib/postgres/data
sudo systemctl enable --now postgresql

# 9. FortClient nordvpn
# the full GUI client
yay -S forticlient nordvpn-bin nordvpn-gui
yay -Rns nordvpn-bin nordvpn-gui