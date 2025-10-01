#!/bin/bash
# Basic Packages
sudo pacman -S pipewire pipewire-alsa pipewire-pulse  \
    alsamixer 
### sof-firmware

# Graphic Drivers


# multilib を有効化
sudo sed -i 's/^#\[multilib\]/[multilib]/' /etc/pacman.conf

# GPU ドライバ選択
read -p "Select intel or ryzen: " c
if [ "$c" = "intel" ]; then
    # Intel => Vulkan, mesa
    sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel
else
    # Ryzen
    sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
fi


sudo pacman -S base-devel gvim wget btop usbutils\
    fcitx5 fcitx5-configtool fcitx5-mozc fcitx5-gtk fcitx5-qt \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    git openssh git-lfs vi less git-filter-repo github-cli \
    kitty wl-clipboard xdg-desktop-portal-hyprland xdg-desktop-portal xdg-desktop-portal-wlr xwayland  \
    dolphin zsh \
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




