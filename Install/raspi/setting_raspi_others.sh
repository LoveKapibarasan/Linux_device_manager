#!/bin/bash

# Graphics
sudo apt install -y mesa-utils mesa-vulkan-drivers vulkan-tools

# Electron
sudo apt install -y libfuse2 

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

# Neovim
sudo apt install -y cmake ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

# PDF JQ
sudo apt install qpdf jq -y