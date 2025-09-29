#!/bin/bash


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

# 8-1. pacman setting
pacman -Syu
pacman -Sy archlinux-keyring 
pacman-key --init
pacman-key --populate archlinux
# Dangerous:
# sed -i 's/#SigLevel=Never.*/SigLevel=Never' /etc/pacman.conf


# 9. GRUB setting(UEFI)
pacman -S grub efibootmgr dosfstools os-prober mtools -y
# GRUB = GRand Unified Bootloader
read -p "Enter GRUB name: " name
grub-install --target=x86_64-efi \
	--efi-directory=/boot \
	--bootloader-id="$name"
grub-mkconfig -o /boot/grub/grub.cfg

# ★ 10. Networking setting
pacman -S networkmanager iwd dialog-y
# iwd = wpa authentication by Intel
# dialog = nmtui, nmcui
systemctl enable NetworkManager

# ★ 11. Never forget to set root password(asdf1234)
passwd

# ★ 12. Exit and reboot

echo "Now exit and reboot!"
exit
