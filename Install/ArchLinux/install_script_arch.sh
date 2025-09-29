#!/bin/bash
# Link: 公式インストールガイド(https://wiki.archlinux.jp/index.php)
# https://qiita.com/Hayatann/items/09c2fee81fcb88d365c8


# 1. change keyboard layout
echo "Japanese = jp106" 
echo "Deutsch = de"
read -p "Enter keyboard layout you want to use: " keyboard

loadkeys "$keyboard"


# 2. Network setting using iwctl

read -p "Do you want to use Ethenet now? (y/n): " USE_ETH
if [[ ! "$USE_ETH" =~ ^[Yy]$ ]]; then

read -p "Enter Wi-Fi device (Example: wlan0): " DEVICE
read -p "Enter SSID: " SSID
read -sp "Enter Wi-Fi password: " PASSWORD
echo

iwctl --passphrase "$PASSWORD" <<EOF
device list
station $DEVICE scan
station $DEVICE get-networks
station $DEVICE connect $SSID
exit
EOF
fi
# 3. partition

lsblk
# Disk
read -p "Enter disk to be cleaned (e.g.: /dev/nvme0n1): " DEV
sgdisk --zap-all "$DEV"
sgdisk -o "$DEV" # reformat
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System Partition" "$DEV"
sgdisk -n 2:0:0 -t 2:8300 -c 2:"Linux root" "$DEV"
sgdisk -p "$DEV"
# cgdisk /dev/nvme0n1
# skip "First sector"
# (ef00, root-8300)=(512M,-3G)

lsblk
# EFI パーティション
read -p "Enter EFI partition device (e.g.: /dev/nvme0n1p1): " EFI_DEV
# Root パーティション
read -p "Enter Root partition device (e.g.: /dev/nvme0n1p2): " ROOT_DEV
echo "EFI partition:  $EFI_DEV"
echo "Root partition: $ROOT_DEV"

read -p "Select the file system(ext4, btrfs): " fs

mkfs.fat -F32 "$EFI_DEV"


case "$fs" in
  ext4)
    mkfs.ext4 -F "$ROOT_DEV"
    ;;
  btrfs)
    mkfs.btrfs -f "$ROOT_DEV"
    ;;
  *)
    echo "Unsupported file system: $fs"
    exit 1
    ;;
esac

# 5. mount 
mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot/efi
mount "$EFI_DEV" /mnt/boot/efi

# 6. Install all necessary packages(with vim)
pacstrap -K /mnt base linux linux-firmware vim 

# 7. create fstab
genfstab -U /mnt >> /mnt/etc/fstab
# -U=use UUID
# Alternative -L = use label
# fstab=file system tables

# 8. chroot
# Around here, failed to execute a command message may be present.
arch-chroot /mnt

