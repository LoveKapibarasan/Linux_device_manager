#!/bin/bash

sudo snap install dbeaver-ce postgresql rabbitmq-server -y
sudo systemctl enable postgresql --now
sudo systemctl enable rabbitmq-server --now

# server
sudo apt install remmina remmina-plugin-rdp -y

# Latex
sudo apt install texlive texlive-full -y
# magick
sudo apt install imagemagick-7.q16  -y

# R
sudo apt install r-base -y
## Rstudio
cd ~/Downloads
wget https://cran.rstudio.com/bin/linux/ubuntu/ -O Rstudio.deb
sudo apt install ./Rstudio.deb -y
cd


# Chrome
cd ~/Downloads
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y


# OBS
sudo apt install obs-studio v4l-utils cheese \ 
pipewire pipewire-pulse wireplumber gstreamer1.0-pipewire \
xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk -y --no-install-recommends

# Video editor
sudo apt install shotcut ffmpeg -y

# Adb
sudo apt install android-tools-adb android-tools-fastboot -y

# Ubuntu-Desktop
sudo apt install ubuntu-desktop -y
gdm3

# DBUS X11
sudo apt install dbus-x11 -y

# Oath
sudo apt-get install oathtool -y

# Wireguard
sudo apt install wireguard -y


# Scrcpy https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md
# for Debian/Ubuntu
sudo apt install ffmpeg libsdl2-2.0-0 adb wget \
                 gcc git pkg-config meson ninja-build libsdl2-dev \
                 libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
                 libswresample-dev libusb-1.0-0 libusb-1.0-0-dev

git clone -o upstream https://github.com/Genymobile/scrcpy
cd scrcpy
./install_release.sh

# or sudo snap install scrcpy

# Syncthing
sudo apt install syncthing -y
syncthing &
## Access localhost:8384 and copy and paste the device ID from other devices

# Quatro
wget https://quarto.org/download/latest/quarto-linux-amd64.deb
sudo dpkg -i quarto-linux-amd64.deb
R
install.packages("knitr")
install.packages("rmarkdown")
q()