#!/bin/bash
# Interactive Raspberry Pi SD card backup script

echo "=== Raspberry Pi SD Backup Tool ==="
echo ""

# Show all block devices
lsblk -dpno NAME,SIZE,MODEL
echo ""

# Ask user for source and destination devices
read -p "Enter the SOURCE device (e.g., /dev/mmcblk0): " SRC_DEV
read -p "Enter the DESTINATION device (e.g., /dev/sda): " DST_DEV

echo ""
echo "Source: $SRC_DEV"
echo "Destination: $DST_DEV"

sync
dd if="$SRC_DEV" of="$DST_DEV" bs=4M status=progress conv=fsync
sync

echo "Backup completed."


