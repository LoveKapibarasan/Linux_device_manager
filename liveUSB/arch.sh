#!/bin/bash

# Import functions
source ../util.sh

root_check

USER_HOME=$(get_user_home)
echo "Using home directory: $USER_HOME"

# Go to a directory where you want to store the ISO
cd "$USER_HOME/Downloads" || exit 1
# Delete old one if exist
sudo rm -rf archlinux-x86_64.iso

# Download the latest Arch Linux ISO from an official mirror
wget https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso


# Ask user for source devices
echo "Enter the SOURCE device (e.g., /dev/mmcblk0): "
select_source_device

sudo dd if=archlinux-x86_64.iso of="$DEVICE" bs=4M status=progress oflag=sync
sudo eject "$DEVICE"
echo "Done."


sudo rm -rf archlinux-x86_64.iso
