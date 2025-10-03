#!/bin/bash
# Basic Packages
sudo pacman -S pipewire pipewire-alsa pipewire-pulse  \
    alsamixer --noconfirm # sof-firmware

# multilib を有効化
sudo sed -i 's/^#\[multilib\]/[multilib]/' /etc/pacman.conf

# GPU Driver
read -p "Select intel or ryzen: " c
if [ "$c" = "intel" ]; then
    # Intel => Vulkan, mesa
    sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel --noconfirm
else
    # Ryzen
    sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon --noconfirm
fi


sudo pacman -S base-devel gvim wget btop usbutils\
    fcitx5 fcitx5-configtool fcitx5-mozc fcitx5-gtk fcitx5-qt \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    git openssh git-lfs vi less git-filter-repo github-cli \
    hyprland kitty wl-clipboard xdg-desktop-portal-hyprland xdg-desktop-portal    
    grim wtype \ 
    xdg-desktop-portal-wlr xwayland  \
    dolphin zsh \
    python python-pip python-setuptools python-wheel python-docs\
    nodejs npm nvm \
    docker docker-compose \
    apparmor  --noconfirm

sudo systemctl enable --now docker
sudo systemctl enable --now apparmor
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service

## Electron
sudo pacman -S atk at-spi2-core at-spi2-atk gtk3 nss alsa-lib libdrm libgbm libxkbcommon libcups \
    fuse2 fuse3  --noconfirm

## clang for Yaneuraou
sudo pacman -S clang llvm lld  --noconfirm

## PDF
sudo pacman -S zathura qpdf --noconfirm


# 4. yay
cd $(get_user_home)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S nkf  --noconfirm

# Pihole
yay -S pi-hole-core pi-hole-ftl pi-hole-web --noconfirm

origin_to_upstream "$USER_HOME/.cache/yay/"
