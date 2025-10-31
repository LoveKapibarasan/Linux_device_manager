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
pacman -Syu --noconfirm
pacman -Sy archlinux-keyring --noconfirm 
pacman-key --init
pacman-key --populate archlinux
# Dangerous:
# sed -i 's/#SigLevel=Never.*/SigLevel=Never' /etc/pacman.conf

pacman -S dosfttools mtools --noconfirm
# 9. GRUB setting(UEFI)
pacman -S grub efibootmgr os-prober --noconfirm
mkdir -p /boot/EFI/
read -p "Enter GRUB name: " name
# grub-install --target=x86_64-efi \
#	--efi-directory=/boot/EFI \
#	--bootloader-id="$name"  
# grub-mkconfig -o /boot/grub/grub.cfg

pacman -S refind --noconfirm
refind-install

# lsblk -f
# read -p "Enter root prtition: " RFS

# UUID=$(blkid -s UUID -o value $RFS)

# cat > /boot/refind_linux.conf <<EOF
# "Arch Linux"  "root=UUID=$UUID rw initrd=/boot/initramfs-linux.img"
# "Arch Linux (fallback)"  "root=UUID=$UUID rw initrd=/boot/initramfs-linux-fallback.img"
# EOF



## Check entry
efibootmgr -v


# ★ 10. Networking setting
pacman -S networkmanager iwd dialog --noconfirm
# iwd = wpa authentication by Intel
# dialog = nmtui, nmcui
systemctl enable NetworkManager

# ★ 11. Never forget to set root password(asdf1234)
passwd

# ★ 12. Exit and reboot
echo "Now reboot!"
exit
