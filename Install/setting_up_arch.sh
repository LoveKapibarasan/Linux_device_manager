# After installation

# 0. Network Setting
nmtui

# 1. Create user(root is dangerous)
useradd -m -G wheel <username>
# Memo:
# -m=create home directory
# -G=join wheel(typically used for sudo)
# “big wheel” = 大物・偉い人
passwd <username>

# 2. pacman setting
pacman -Syu
pacman -Sy archlinux-keyring 
# Memo:
# PGP=Pretty Good Privacy
# 1.暗号化　2.署名　3.鍵管理

# 3. Install
# 3-1. sudo
pacman -S sudo
# Memo:
# pacman=package manager
# -S=Sync
# -Sy=update package database
# -u=update all package
(EDITOR=vim) visudo
# visudo=special command to edit /etc/sudoers
# uncomment %wheel ALL=(ALL:ALL) ((NOPASSWD:)) ALL to allow wheel group to use sudo 

# Change user
su - <username>

# 3-3. Basic Packages
sudo pacman -S base-devel

# 3-4. Install git
sudo pacman -S git openssh git-lfs vi less git-filter-repo github-cli
git --version


chmod 700 ~/.ssh              # ディレクトリは自分だけアクセス
chmod 600 ~/.ssh/id_rsa       # 秘密鍵は自分だけ読める
chmod 644 ~/.ssh/id_rsa.pub   # 公開鍵は誰でも読めてOK



# 3-5. Install node.js
sudo pacman -S nodejs npm nvm
node -v
npm -v

sudo vim ~/.zshrc
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"


# 3-6. For Electron
sudo pacman -Syu atk at-spi2-core at-spi2-atk gtk3 nss alsa-lib libdrm libgbm libxkbcommon libcups
sudo pacman -S fuse2 fuse3

# 3-7. Japanese setting
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji
sudo pacman -S fcitx5 fcitx5-configtool fcitx5-mozc fcitx5-gtk fcitx5-qt

# 1. /etc/environment
# 2. ~/.zprofile
# 3. ~/.config/hypr/hyprland.conf

# 3-8. Install Python
# Then setting up shutdown-cui

# 1. Python core
sudo pacman -Syu python

# 2. Essential packaging tools
sudo pacman -S python-pip python-setuptools python-wheel

# 3. Developer utilities
sudo pacman -S python-virtualenv python-tox python-pytest

# 4. Documentation
sudo pacman -S python-docs


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
sudo pacman -Syu clang llvm lld

# 4. WM
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


# Make zsh as default
chsh -s $(which zsh)

vim  ~/.zprofile
#if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
#  exec Hyprland
#fi

# kitty automatically care system shell default

# 5 Network settings
sudo pacman -Syu bind wget

# 6 time zone
sudo timedatectl set-timezone Europe/Berlin

# 7 Audio
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol helvum easyeffects sof-firmware

# 8 Fingerprint
sudo pacman -S fprintd
fprintd-enroll $USER -f right-index-finger
sudo -E vim /etc/pam.d/system-local-login

# 9 yay
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S nkf


# 10. FortClient nordvpn
# the full GUI client
yay -S forticlient nordvpn-bin nordvpn-gui

# 11. Graphic Drivers
# Intel => Vulkan, mesa 
sudo pacman -Syu mesa lib32-mesa vulkan-intel vulkan-radeon lib32-vulkan-intel lib32-vulkan-radeon

# 12. PDF
sudo pacman -S okular qpdf

# 13. Authenticator
sudo pacman -S flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.belmoussaoui.Authenticator

