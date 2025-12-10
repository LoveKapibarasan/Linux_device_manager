#!/bin/bash
# Basic Packages
sudo pacman -S pipewire pipewire-alsa pipewire-pulse  \
    alsa-utils --noconfirm # sof-firmware

# multilib が無効の場合のみ有効化
if grep -q "^#\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
    echo "multilib enabled"
fi

# パッケージデータベースを更新
sudo pacman -Sy
# GPU Driver
sudo pacman -S vulkan-tools mesa lib32-mesa --noconfirm 
read -p "Select intel or ryzen: " c
if [ "$c" = "intel" ]; then
    # Intel => Vulkan, mesa
    sudo pacman -S vulkan-intel lib32-vulkan-intel --noconfirm
else
    # Ryzen
    sudo pacman -S vulkan-radeon lib32-vulkan-radeon --noconfirm
fi

# Reflector 
sudo pacman -S reflector --noconfirm

echo "Japan, Germany, USA"

read -p "Enter your regidence." address
# Mirrorlistを最適化
sudo reflector \
    --country "$address" \
    --age 12 \
    --protocol https \
    --sort rate \
    --save /etc/pacman.d/mirrorlist

# 結果を確認
if [ $? -eq 0 ]; then
    echo "Success! Enabling auto update."
    sudo systemctl enable reflector.timer
    sudo systemctl start reflector.timer
    
    # Update Package database
    sudo pacman -Sy
    
else
    echo "Error!"
    exit 1
fi

# Purge
sudo pacman -Rns nano vim

# Basic Packages
sudo pacman -S base-devel wget btop usbutils udisks2\
    fcitx5 fcitx5-configtool fcitx5-mozc fcitx5-gtk fcitx5-qt \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    git openssh git-lfs vi less git-filter-repo github-cli \
    hyprland alacritty wl-clipboard xdg-desktop-portal-hyprland xdg-desktop-portal xdg-desktop-portal-wlr xwayland \ 
    grim wtype \ 
    pcmanfm waybar rofi dunst zsh \
    python python-pip python-setuptools python-wheel python-docs\
    nodejs npm nvm \
    docker docker-compose \
    neovim qutebrowser --noconfirm
    # apparmor
    # sway gvim

sudo systemctl enable --now docker
sudo systemctl enable --now apparmor
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.servic

## Electron
sudo pacman -S atk at-spi2-core at-spi2-atk gtk3 nss alsa-lib libdrm libgbm libxkbcommon libcups \
    fuse2 fuse3  --noconfirm

## clang for Yaneuraou
sudo pacman -S clang llvm lld  --noconfirm

## PDF
### Zathura need framework and backend
sudo pacman -S zathura zathura-pdf-poppler qpdf pdfjs --noconfirm
### Image Viewer VLC
sudo pacman -S imv mpv ffmpeg --noconfirm

## USB
sudo pacman -S udiskie gvfs gvfs-mtp udisks2 --noconfirm

# 4. yay
cd $(get_user_home)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S nkf --noconfirm
# yay -S b43-firmware # broadcom

# Pihole
yay -S pi-hole-core pi-hole-ftl pi-hole-web --noconfirm

origin_to_upstream "$USER_HOME/.cache/yay/"
