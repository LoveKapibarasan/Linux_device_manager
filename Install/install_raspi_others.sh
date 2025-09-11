#!/bin/bash

#  FortClient
sudo apt install openfortivpn -y
sudo sh -c 'cat >> /etc/openfortivpn/config <<EOF
host = sslvpn.oth-regensburg.de
port = 443
realm = vpn-default
trusted-cert = 364fb4fa107e591626b3919f0e7f8169e9d2097974f3e3d55e56c7c756a1f94a
username = abc12345
password = meinpasswort
EOF'
sudo openfortivpn

# Graphics
sudo apt install -y mesa-utils mesa-vulkan-drivers vulkan-tools

# Audio tools are installed
alsamixer

# Electron
sudo apt install -y libfuse2 

#  2FA
sudo apt install -y oathtool
oathtool --totp -b "<secret_key>"

# pyenv
curl https://pyenv.run | bash

sudo apt install -y \
    build-essential \
    libbz2-dev \
    libncurses5-dev libncursesw5-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    tk-dev \
    liblzma-dev \
    zlib1g-dev \
    libgdbm-dev \
    uuid-dev \
    libssl-dev

