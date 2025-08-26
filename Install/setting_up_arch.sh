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

# 3-2. X.Org Server for GUI
sudo pacman -S xorg-server xorg-xinit xkeyboard-config xorg-xkbcomp xterm
startx # "pkill Xorg" to kill
# memo cat <log_file> | grep "EE" # to extract error
# Add setxkbmap jp & to ~/.xinitrc


# 3-3. Basic Packages
sudo pacman -S base-devel

# 3-4. Install git
sudo pacman -S git openssh vi
git --version
git config --global user.name "<name>"
git config --global user.email "<email_address>"
git config --list

# 3-5. Install node.js
sudo pacman -S nodejs npm
node -v
npm -v

# 3-6. For Electron
sudo pacman -Syu atk at-spi2-core at-spi2-atk gtk3 nss alsa-lib libdrm libgbm libxkbcommon libcups
sudo pacman -S fuse2 fuse3

# 3-7. Japanese setting
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji

sudo pacman -S fcitx5 fcitx5-configtool fcitx5-mozc fcitx5-gtk fcitx5-qt
# Add ~/.xinitrc, ~/.xprofile /etc/environment(no export) 
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS=@im=fcit
# fcitx5 d

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
sudo systemctl enable --now docker
# without sudo
sudo usermod -aG docker $USER
docker run hello-world

sudo pacman -S p7zip

# 3-11. Install code explorer
sudo pacman -S pcmanfm
# 1. Add Vim extension
# 2. enable autosave
