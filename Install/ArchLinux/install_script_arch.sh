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


mkfs.fat -F32 "$EFI_DEV"
mkfs.btrfs "$ROOT_DEV"
# or ext4(Basic), xfs, f2fs… # Memo:
# 1. EFI = Extensible Firmware Interface, BIOS(Basic I/O System) の後継, OS とハードウェアのあいだを仲介するファームウェア
# 2. mkfs=make file system
# 3. Btrfs=B-tree file system(Snap, Compress)

# 5. mount 
mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot
mount "$EFI_DEV" /mnt/boot

# 6. Install all necessary packages(with vim)
pacstrap -K /mnt base linux linux-firmware vim 

# 7. create fstab
genfstab -U /mnt >> /mnt/etc/fstab
# -U=use UUID
# Alternative -L = use label
# Memo:
# fstab=file system tables

# 8. chroot
arch-chroot /mnt

