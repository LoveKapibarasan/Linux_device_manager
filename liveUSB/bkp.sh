#!/bin/bash

echo "=== Backup Tool ==="
echo ""

source ../util.sh
root_check

# Ask user for source and destination devices
echo "Enter the SOURCE device (e.g., /dev/mmcblk0): "
select_source_device
echo "Enter the DESTINATION device (e.g., /dev/sda): "
select_device
DST_DEV="$DEVICE"

echo ""
echo "Source: $SRC_DEV"
echo "Destination: $DST_DEV"

sync
dd if="$SRC_DEV" of="$DST_DEV" bs=4M status=progress conv=fsync
sync

echo "Backup completed."