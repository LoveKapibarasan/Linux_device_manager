#!/bin/bash

#  FortClient
sudo apt install openfortivpn -y

#  2FA
sudo apt install -y oathtool

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

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Camera
sudo apt install -y cheese
