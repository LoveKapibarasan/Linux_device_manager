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
sudo pacman -S xorg-server xorg-xinit xterm
startx # "pkill Xorg" to kill

# 3-3. Basic Packages
sudo pacman -S base-devel

# 3-4. Install git
sudo pacman -S git
git --version
git config --global user.name "<name>"
git config --global user.email "<email_address>"
git config --list

# 3-5. Install node.js
sudo pacman -S nodejs npm
node -v
npm -v
