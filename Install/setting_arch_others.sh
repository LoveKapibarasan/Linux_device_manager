#!/bin/bash

# After installation

# 0. Network Setting
nmtui

read -p username
# 1. Create user(root is dangerous)
useradd -m -G wheel $username
# Memo:
# -m=create home directory
# -G=join wheel(typically used for sudo)
# “big wheel” = 大物・偉い人
passwd $username

pacman -Syyu

# 3. Install
# 3-1. sudo
pacman -S sudo
(EDITOR=vim) visudo
echo "uncomment '%wheel ALL=(ALL:ALL) ((NOPASSWD:)) ALL' to allow wheel group to use sudo "
# visudo=special command to edit /etc/sudoers


# Change user
su - $username

# 3-3. Basic Packages
sudo pacman -S base-devel

# 3-4. Install git
sudo pacman -S git openssh git-lfs vi less git-filter-repo github-cli
git --version

# 3-5. Install node.js
sudo pacman -S nodejs npm nvm
node -v
npm -v

# 3-6. For Electron
sudo pacman -S atk at-spi2-core at-spi2-atk gtk3 nss alsa-lib libdrm libgbm libxkbcommon libcups
sudo pacman -S fuse2 fuse3

# 3-7. Japanese setting
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji
sudo pacman -S fcitx5 fcitx5-configtool fcitx5-mozc fcitx5-gtk fcitx5-qt

# 1. /etc/environment
sudo bash -c 'cat >> /etc/environment << "EOF"
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
EOF'
# 2. ~/.zprofile, ~/.config/hypr/hyprland.conf

# 3-8. Install Python
# Then setting up shutdown-cui

# 1. Python core
sudo pacman -S python

# 2. Essential packaging tools
sudo pacman -S python-pip python-setuptools python-wheel

# 3. Developer utilities
sudo pacman -S python-virtualenv python-tox python-pytest

# 4. Documentation
sudo pacman -S python-docs

# 5. Pyenv
yay -S pyenv pyenv-virtualenv

# 3-9. Purge vim and install gvim
sudo pacman -R vim
sudo pacman -S gvim

# 3-10. Install PostgreSQL 7z docker
sudo pacman -S postgresql
# Initialize database cluster
sudo -iu postgres initdb -D /var/lib/postgres/data
sudo systemctl enable --now postgresql

sudo pacman -S docker
sudo pacman -Syu docker-compose
sudo systemctl enable --now docker
# without sudo
sudo usermod -aG docker $USER
docker run hello-world

sudo pacman -S p7zip

# 3-11. Install code explorer
sudo pacman -S dolphin
# 1. Add Vim extension
# 2. enable autosave

# 3-12. clang
sudo pacman -S clang llvm lld

# 4. WM
## Hyprland
sudo pacman -S kitty wl-clipboard xdg-desktop-portal-hyprland xdg-desktop-portal xdg-desktop-portal-wlr zsh
 
systemctl --user status xdg-desktop-portal-hyprland
sudo pacman -S  dunst waybar grim slurp wtype
# kitty → terminal
# waybar → panel
# dunst → Notification
# wl-clipboard → Clipboard (Wayland)
# grim/slurp → screenshot
# xdg-desktop-portal-hyprland → for Electron/Flatpak
# wtype → for python-util, screenshot
hyprctl reload
hyprland

## Sway
sudo pacman -S sway swaybg swayidle swaylock xorg-xwayland


# Make zsh as default
chsh -s $(which zsh)
# kitty automatically care system shell default

# 5 Network settings
sudo pacman -Syu bind wget

# 6 Audio
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol helvum easyeffects sof-firmware

# 7 Fingerprint
sudo pacman -S fprintd
fprintd-enroll $USER -f right-index-finger
sudo -E vim /etc/pam.d/system-local-login

# 8 yay
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S nkf


# 9. FortClient nordvpn
# the full GUI client
yay -S forticlient nordvpn-bin nordvpn-gui
yay -Rns nordvpn-bin nordvpn-gui


# 11. Graphic Drivers

# sudo /etc/pacman.conf
#[multilib]
#Include = /etc/pacman.d/mirrorlist

# Intel => Vulkan, mesa 
sudo pacman -S mesa lib32-mesa vulkan-intel vulkan-radeon lib32-vulkan-intel lib32-vulkan-radeon

# Ryzen
sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon

# 12. PDF
sudo pacman -S okular qpdf

# 13. Btop
sudo pacman -S btop

# 14. Tailscale Wayvnc openssh
sudo pacman -S wayvnc
vncpasswd ~/.vncpasswd
chmod 600 ~/.vncpasswd
wayvnc 0.0.0.0 5900 -p ~/.vncpasswd
ss -tlnp | grep 5900 # This should not be 127.0.0.1

sudo pacman -S openssh
sudo systemctl enable --now sshd
systemctl status sshd
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# From user, ssh <username>@xx.xx.xx.xx

sudo pacman -S tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
tailscale ip -4
tailscale ping xx.xx.xx.xx # It should return "pong"
sudo systemctl enable --now sshd
sudo tailscale up --accept-dns=falseo

## openssh
sudo pacman -S openssh

sudo vim /etc/ssh/sshd_config
# PasswordAuthentication no
sudo systemctl restart sshd


# 15. SELinux or AppArmor
# Apparmor
sudo pacman -S apparmor
sudo systemctl enable --now apparmor

# SELinux
## Check
zgrep SELINUX /proc/config.gz # CONFIG_SECURITY_SELINUX=y
sudo yay -S selinux-utils selinux-policy

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="selinux=1 security=selinux enforcing=0 /' /etc/default/grub

sudo grub-mkconfig -o /boot/grub/grub.cfg

## Apply SELinux context to files
sudo setfiles -F /etc/selinux/targeted/contexts/files/file_contexts /

## SELinux Config
sudo tee /etc/selinux/config <<'EOF'
SELINUX=permissive
SELINUXTYPE=targeted
EOF

# 16. wget
sudo pacman -S wget
