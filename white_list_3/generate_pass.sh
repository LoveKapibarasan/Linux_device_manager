#!/bin/bash
set -e

# Ask if using Docker or standard Pi-hole
read -p "Are you using Docker to run Pi-hole? (y/n): " use_docker

sudo touch /opt/pihole/.env
# 1. Generate random password and save to .env
pw=$(openssl rand -base64 20)
echo "ADMIN_PASSWORD=$pw" | sudo tee /opt/pihole/.env > /dev/null
sudo chmod 600 /opt/pihole/.env
echo "[OK] New password saved to /opt/pihole/.env"

# 2. Ask for USB device
lsblk
read -p "Enter USB device (e.g. /dev/sda1): " usbdev
read -p "Enter temporary mount path (e.g. /mnt/usb): " usbpath

# 3. Detect if device already mounted
already_mounted=$(lsblk -o NAME,MOUNTPOINT | grep "$(basename $usbdev)" | awk '{print $2}')

if [ -n "$already_mounted" ]; then
    echo "[INFO] Device $usbdev already mounted at $already_mounted"
    final_mount="$already_mounted"
else
    # Create mount point if needed
    if [ ! -d "$usbpath" ]; then
        sudo mkdir -p "$usbpath"
    fi
    echo "[INFO] Mounting $usbdev to $usbpath ..."
    sudo mount "$usbdev" "$usbpath"
    final_mount="$usbpath"
fi

# 4. Ask where inside the USB to store backup
read -p "Enter directory inside USB to store backup (e.g. pihole_backup): " usbdir
fullpath="$final_mount/$usbdir"
if [ ! -d "$fullpath" ]; then
    echo "[INFO] Creating directory $fullpath ..."
    sudo mkdir -p "$fullpath"
fi

# 5. Save backup
sudo cp /opt/pihole/.env "$fullpath/.env.backup"
echo "[OK] Password backup saved to $fullpath/.env.backup"

# 6. If we mounted it ourselves, unmount again
if [ -z "$already_mounted" ]; then
    sudo umount "$usbpath"
    echo "[OK] USB unmounted from $usbpath"
else
    echo "[INFO] USB was already mounted at $already_mounted, leaving it mounted"
fi

# 7. If not using Docker, delete .env and set password
if [[ "$use_docker" =~ ^[Nn]$ ]]; then
    sudo rm -f /opt/pihole/.env
    sudo pihole setpassword "$pw"
    echo "[OK] .env removed (Docker installation)"
else
    echo "[INFO] .env kept (non-Docker installation)"
fi

