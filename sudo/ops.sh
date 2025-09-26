#!/bin/bash

# Import functions
. ../util.sh

root_check

# Safer: sudo visudo -f /etc/sudoers.d/ops
sudo tee /etc/sudoers.d/ops > /dev/null <<EOF
# Log
Cmnd_Alias SERVICE_OPS = /usr/bin/systemctl start *, /usr/bin/systemctl restart *

# Package management (Arch + Debian/Ubuntu)
Cmnd_Alias PACKAGE_MGR = /usr/bin/pacman, /usr/bin/yay, /usr/bin/apt, /usr/bin/apt-get

# VPN (動的に取得したフルパスを埋め込む)
Cmnd_Alias VPN_OPS =  $(which openfortivpn) # $(which nordvpn)

# Apply to ops
%ops ALL=(ALL:ALL) NOPASSWD: SERVICE_OPS, PACKAGE_MGR, VPN_OPS
EOF


# permission should be 440
sudo chmod 0440 /etc/sudoers.d/ops

for u in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    sudo usermod -aG systemd-journal "$u"
done

if [ -z "$(getent group ops)" ];then
    sudo groupadd ops
fi