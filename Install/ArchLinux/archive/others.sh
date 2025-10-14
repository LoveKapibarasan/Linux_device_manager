#!/bin/bash

# Fingerprint
sudo pacman -S fprintd
fprintd-enroll $USER -f right-index-finger

## Camera
sudo pacman -S cheese libreoffice-fresh --noconfirm

# PostgreSQL
sudo pacman -S postgresql
## Initialize database cluster
sudo -iu postgres initdb -D /var/lib/postgres/data
sudo systemctl enable --now postgresql

# HP Printer
sudo pacman -S cups hplip
sudo systemctl enable --now cups.service

# Latex
# https://tug.org/texlive/quickinstall.html
rm -rf /usr/local/texlive
rm -rf ~/.texlive*
mkdir ~/latex
cd ~/latex
curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - 
# note final - on that command line. It means tar get input from |
cd install-tl-2*
perl ./install-tl --no-interaction

# FortClient nordvpn
sudo pacman -S openfortivpn --noconfirm
yay -S forticlient --noconfirm
yay -S nordvpn-bin --noconfirm
systemctl enable --now nordvpnd
nordvpn login --token "$token"
nordvpn connect "$country"
nordvpn set dns 127.0.0.1
nordvpn set dns off
nordvpn set autoconnect on

# OAuthTool
yay -S oath-toolkit
