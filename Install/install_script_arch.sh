# Link: 公式インストールガイド(https://wiki.archlinux.jp/index.php)
# https://qiita.com/Hayatann/items/09c2fee81fcb88d365c8

# 0. create liveUSB using ventoy

# 1. change keyboard layout
loadkeys jp106

# 2.Ensure it returns 64 t use GRUB
cat /sys/firmware/efi/fw_platform_size

# 3. Network setting using iwctl
iwctl
device list
# scan network
station <device> scan
station <device> get-networks
station <device> connect <SSID> 
# Then enter password
exit

# 4. partition
fdisk -l
# or lsblk
# Memo:
# dev = device file 
# NVMe=Non-Volatile Memory Express 
# n = name space
# p = partition
# lsblk = list block devices
cgdisk /dev/nvme0n1
# skip "First sector"
# (ef00, root-8300)=(512M,-3G)
mkfs.fat -F32 /dev/nvme0n1p<x> # EFI
# Memo:
# 1. EFI = Extensible Firmware Interface
# BIOS(Basic I/O System) の後継
# OS とハードウェアのあいだを仲介するファームウェア
# 2. mkfs=make file system
mkfs.btrfs /dev/nvme0n1p<y> # root
# Btrfs=B-tree file system

# 5. mount 
mount /dev/nvme0n1p<y> /mnt
mkdir -p /mnt/boot
munt /dev/nvme0n1p<x> /mnt/boot

# 6. Install all necessary packages(with vim)
pacstrap -K /mnt base linux linux-firmware vim 

# 7. create fstab
genfstab -U /mnt >> /mnt/etc/fstab
# -U=use UUID
# Alternative -L=use label
# Memo:
# fstab=file system tables

# 8. chroot
arch-chroot /mnt

# 8-1. locale
# use UTC
vim /etc/locale.gen
# Uncomment en_US.UTF-8 UTF-8, ja_JP.UTF-8 UTF-8, de_DE.UTF-8 UTF-8
locale-gen
# Memo:
# This creates candidates.

vim /etc/locale.conf
# Add LANG=en_US.UTF-8
# Memo: default locale

# Keyboard
vim /etc/vconsole.conf
# Add 
# KEYMAP=jp106

# 8-2. Hostname
vim /etc/hostname # write only name (pc)
vim /etc/hosts

# 127.0.0.1	localhost
# ::1		localhost
# 127.0.1.1	<hostname>.localdomain	<hostname>

# 9. GRUB setting
pacman -S grub efibootmgr dosfstools os-prober mtools
# GRUB=GRand Unified Bootloader

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=<name>
# i386-pc for UEFI(GPT)
# GPT=GUID Partition Table
# GPT=Gnerative Pre-trained Transformer
# See #2.
# Update
grub-mkconfig -o /boot/grub/grub.cfg

# 10. Networking setting
pacman -S networkmanager iwd dialog
# iwd=for wpa authentication by Intel
# dialog=nmtui
systemctl enable NetworkManager

# 11. Never forget to set root password
passwd # asdf1234

# 12.
exit
reboot
