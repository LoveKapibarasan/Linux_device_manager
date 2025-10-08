#!/bin/bash

# Purge LXDE
## Default Menu
dpkg -l | grep -i "^ii.*\slx"
sudo apt purge lxmenu-data libmenu-cache-bin libmenu-cache3 lxde-icon-theme lxpolkit lxsession-data -y


# Graphics
sudo apt install -y mesa-utils mesa-vulkan-drivers vulkan-tools

# Electron
sudo apt install -y libfuse2 

# Neovim
sudo apt install -y cmake ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

# PDF JQ
sudo apt install qpdf zathura libjs-pdf jq -y
