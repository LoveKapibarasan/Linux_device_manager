#!/bin/bash

mkdir -p /tmp/bkp
cp /home /tmp/bkp

COUNT=10240
NAME=crypt_home
FILE_SYSTEM=btrfs # mkfs.ext4


# 1. 
sudo dd if=/dev/zero of=/${NAME}.img bs=1M count=${COUNT} 
## /dev/zero = fill with 0
sudo cryptsetup luksFormat /${NAME}.img
##  cryptsetup luksFormat = create a new encrypted partition
sudo cryptsetup open /${NAME}.img ${NAME}
## Create a file system
sudo mkfs.${FILE_SYSTEM} /dev/mapper/${NAME}

# 2. Copy /home
## mount
mount /dev/mapper/crypt_home /mnt
## rsync → A command specialized for copying (more reliable than cp)

    ## -a → Archive mode (preserves permissions and timestamps)

    ## -X → Also copies extended attributes

    ## -S → Copies sparse files efficiently

    # /home/ → Source directory (the trailing / is important — it means “contents only”)

rsync -aXS /home/ /mnt/

# 3. Configuration

crypt_home   /secure_home.img   none   luks



/dev/mapper/crypt_home   /home   ${FILE_SYSTEM}  defaults   0 2


# 5. Reboot
umount /home
mount /home
reboot
