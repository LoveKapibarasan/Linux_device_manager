#!/bin/bash

# Import functions
. ../util.sh
root_check

# 0. Network Setting
nmtui

# 1. Create a user
read -p "Enter new username:" username
useradd -m -G wheel $username
passwd $username

pacman -Syyu

# 3. Install
# sudo
pacman -S sudo

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sudo visudo -c 
su - $username

# Basic Packages
sudo pacman -S pipewire pipewire-alsa pipewire-pulse  \
    alsamixer \ 
### sof-firmware

read -p "intel(i) or ryzen(r)" choice


sudo pacman -S base-devel gvim wget btop \
    fcitx5 fcitx5-configtool fcitx5-mozc fcitx5-gtk fcitx5-qt \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    git openssh git-lfs vi less git-filter-repo github-cli \
    kitty wl-clipboard xdg-desktop-portal-hyprland xdg-desktop-portal xdg-desktop-portal-wlr  \
    code dolphin zsh \
    python python-pip python-setuptools python-wheel python-docs\
    nodejs npm nvm \
    docker docker-compose \
    apparmor

sudo systemctl enable --now docker
sudo systemctl enable --now apparmor


## Electron
sudo pacman -S atk at-spi2-core at-spi2-atk gtk3 nss alsa-lib libdrm libgbm libxkbcommon libcups \
    fuse2 fuse3
## clang
sudo pacman -S clang llvm lld

## PDF
sudo pacman -S okular qpdf

# 4. yay
cd $(get_user_home)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S nkf

# Pyenv
yay -S pyenv pyenv-virtualenv


# 11. Graphic Drivers

# sudo /etc/pacman.conf
#[multilib]
#Include = /etc/pacman.d/mirrorlist

# Intel => Vulkan, mesa 
sudo pacman -S mesa lib32-mesa vulkan-intel vulkan-radeon lib32-vulkan-intel lib32-vulkan-radeon

# Ryzen
sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon