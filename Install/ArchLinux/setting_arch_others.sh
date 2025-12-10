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

systemctl enable systemd-resolved && systemctl restart systemd-resolved

pacman -Syyu

# 3. Install
# sudo
pacman -S sudo --noconfirm

sed -i 's/^# \(%wheel ALL=(ALL:ALL) ALL\)$/\1/' /etc/sudoers
# sudo visudo
sudo visudo -c 
su - $username


