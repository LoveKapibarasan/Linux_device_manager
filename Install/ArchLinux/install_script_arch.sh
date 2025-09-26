#!/bin/bash
# Link: 公式インストールガイド(https://wiki.archlinux.jp/index.php)
# https://qiita.com/Hayatann/items/09c2fee81fcb88d365c8


# 1. change keyboard layout
echo "Japanese = jp106" 
echo "Deutsch = de"
read -p "Enter keyboard layout you want to use" keyboard

loadkeys keyboard


# 2. Network setting using iwctl

read -p "Do you want to use Wi-Fi now? (y/n): " USE_WIFI
if [[ ! "$USE_WIFI" =~ ^[Yy]$ ]]; then
    echo "Skipping Wi-Fi setup."
    exit 0
fi

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

# 3. partition

lsblk
cgdisk /dev/nvme0n1
# EFI パーティション
read -p "Enter EFI partition device (例: /dev/nvme0n1p1): " EFI_DEV
# Root パーティション
read -p "Enter Root partition device (例: /dev/nvme0n1p2): " ROOT_DEV
echo "EFI partition:  $EFI_DEV"
echo "Root partition: $ROOT_DEV"
# Memo:
# n = name space
# p = partition
# lsblk = list block devices
cgdisk /dev/nvme0n1
# skip "First sector"
# (ef00, root-8300)=(512M,-3G)

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

# ★ 8-0. pacman setting
pacman -Syu
pacman -Sy archlinux-keyring 
pacman-key --init
pacman-key --populate archlinux
# Dangerous:
sed -i 's/#SigLevel=Never.*/SigLevel=Never' /etc/pacman.conf


# 8 locale
## Timezone
echo "Select timezone:"
echo "1) Tokyo"
echo "2) Berlin"
read -p "Enter number: " TZ_CHOICE

case "$TZ_CHOICE" in
  1) TIMEZONE="Asia/Tokyo" ;;
  2) TIMEZONE="Europe/Berlin" ;;
  *) echo "Invalid choice, defaulting to Tokyo"; TIMEZONE="Asia/Tokyo" ;;
esac

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "Timezone set to $TIMEZONE"
hwclock --systohc # update RTC
timedatectl set-ntp true


# ★ 9. GRUB setting(UEFI)
pacman -S grub efibootmgr dosfstools os-prober mtools
# GRUB = GRand Unified Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=<name_ArchLinux>
grub-mkconfig -o /boot/grub/grub.cfg

# ★ 10. Networking setting
pacman -S networkmanager iwd dialog
# iwd = wpa authentication by Intel
# dialog = nmtui
systemctl enable NetworkManager

# ★ 11. Never forget to set root password(asdf1234)
passwd

# ★ 12. Exit and reboot
exit
reboot
