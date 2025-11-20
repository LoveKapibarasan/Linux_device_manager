#!/bin/bash

# Fingerprint
pacman -S fprintd
fprintd-enroll $USER -f right-index-finger

## Camera
pacman -S cheese libreoffice-fresh --noconfirm

# PostgreSQL
pacman -S postgresql postgis --noconfirm
systemctl enable --now postgresql

# HP Printer
pacman -S cups hplip
systemctl enable --now cups.service

# Latex
# https://tug.org/texlive/quickinstall.html
rm -rf /usr/local/texlive
rm -rf "${HOME}/.texlive*"
mkdir "${HOME}/latex"
cd "${HOME}/latex"
curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - 
# note final - on that command line. It means tar get input from |
cd install-tl-2*
perl ./install-tl --no-interaction

# R
pacman -S r --noconfirm

# VPN
pacman -S openfortivpn --noconfirm
# https://aur.archlinux.org/packages/forticlient
yay -S forticlient --noconfirm
# https://aur.archlinux.org/packages/nordvpn-bin
yay -S nordvpn-bin --noconfirm
systemctl enable --now nordvpnd
nordvpn login --token "$token"
nordvpn connect "$country"
nordvpn set dns 127.0.0.1
nordvpn set dns off
nordvpn set autoconnect on
# https://aur.archlinux.org/packages/mozillavpn
yay -S mozillavpn


# RabbitMQ
pacman -S rabbitmq erlang
systemctl enable --now rabbitmq

# MFA
# https://archlinux.org/packages/extra/x86_64/oath-toolkit/
sudo pacman -S oath-toolkit

# pnpm
sudo pacman -S pnpm
