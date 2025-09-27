#!/bin/bash

# SELinux
## Check
zgrep SELINUX /proc/config.gz # CONFIG_SECURITY_SELINUX=y
sudo yay -S selinux-utils selinux-policy

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="selinux=1 security=selinux enforcing=0 /' /etc/default/grub

sudo grub-mkconfig -o /boot/grub/grub.cfg

## Apply SELinux context to files
sudo setfiles -F /etc/selinux/targeted/contexts/files/file_contexts /

## SELinux Config
sudo tee /etc/selinux/config <<'EOF'
SELINUX=permissive
SELINUXTYPE=targeted
EOF