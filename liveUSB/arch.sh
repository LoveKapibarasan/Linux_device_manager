#!/usr/bin/env bash


# Import functions
. ../util.sh

root_check

USER_HOME=$(get_user_home)
echo "Using home directory: $USER_HOME"

# Go to a directory where you want to store the ISO
cd "$USER_HOME/Downloads" || exit 1
# Delete old one if exist
sudo rm -rf archlinux-x86_64.iso

# Download the latest Arch Linux ISO from an official mirror
wget https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso

# Show block devices so user can choose
lsblk

# Ask user for the target device
read -rp "Enter the target device (e.g., /dev/sdX): " target

# Confirm before proceeding
echo "You entered: $target"
read -rp "Are you sure you want to write to $target? This will erase all data! (yes/NO): " confirm
device=$(echo "$device" | tr -cd '[:alnum:]/')

if [[ "$confirm" == "yes" ]]; then
    sudo dd if=archlinux-x86_64.iso of="$target" bs=4M status=progress oflag=sync
    sudo eject "$target"
    echo "Done. You can now remove the USB."
else
    echo "Aborted."
fi

sudo rm -rf archlinux-x86_64.iso


