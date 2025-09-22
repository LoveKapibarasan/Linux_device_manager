#!/bin/bash
# Link: 公式インストールガイド(https://wiki.archlinux.jp/index.php)
# https://qiita.com/Hayatann/items/09c2fee81fcb88d365c8

# 0. create liveUSB using ventoy

# 1. change keyboard layout
read -p "Enter keyboard layout you want to use" keyboard
echo "Japanese = jp106 Deutsch = de"
loadkeys keyboard

# 2.
echo "Ensure it returns 64t use GRUB"
cat /sys/firmware/efi/fw_platform_size

# 3. Network setting using iwctl

read -p "Do you want to use Wi-Fi now? (y/n): " USE_WIFI
if [[ ! "$USE_WIFI" =~ ^[Yy]$ ]]; then
    echo "Skipping Wi-Fi setup."
    exit 0
fi

read -p "Enter Wi-Fi device (例: wlan0): " DEVICE
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

# 4. partition

lsblk
cgdisk /dev/nvme0n1
# EFI パーティション
read -p "Enter EFI partition device (例: /dev/nvme0n1p1): " EFI_DEV
# Root パーティション
read -p "Enter Root partition device (例: /dev/nvme0n1p2): " ROOT_DEV
echo "EFI partition:  $EFI_DEV"
echo "Root partition: $ROOT_DEV"
# Memo:
# dev = device file 
# NVMe=Non-Volatile Memory Express 
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
vim /etc/pacman.conf
[options]
SigLevel = Never

# Memo:
# PGP=Pretty Good Privacy
# 1.暗号化　2.署名　3.鍵管理


# 8-1. locale
## Timezone
echo "Select timezone:"
echo "1) Tokyo"
echo "2) Berlin"
read -p "Enter number [1-2]: " TZ_CHOICE

case "$TZ_CHOICE" in
  1) TIMEZONE="Asia/Tokyo" ;;
  2) TIMEZONE="Europe/Berlin" ;;
  *) echo "Invalid choice, defaulting to Tokyo"; TIMEZONE="Asia/Tokyo" ;;
esac

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "Timezone set to $TIMEZONE"
hwclock --systohc # update RTC
timedatectl set-ntp true


## Locale(Candidates)
sed -i 's/^# *\(de_DE.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^# *\(ja_JP.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
## Default
echo 'LANG=en_US.UTF-8' | tee -a /etc/environment


## Keyboard
read -p "Enter keyboard layout (ex: jp106, us): " KEYMAP
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
## Check
localectl status
setxkbmap -query


# ★ 8-2. Hostname
# hostname = pc
# ===== Hostname =====
read -p "Enter hostname: " HOSTNAME
echo "${HOSTNAME}" > /etc/hostname

# ★ ===== Hosts =====
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# ★ 9. GRUB setting(UEFI)
pacman -S grub efibootmgr dosfstools os-prober mtools
# GRUB = GRand Unified Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=<name_ArchLinux>

# Update
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
