#!/usr/bin/env bash
sudo pihole uninstall


#=== NetworkManager ===
sudo sed -i '/^\s*dns=none\s*$/d' /etc/NetworkManager/NetworkManager.conf
cat /etc/NetworkManager/NetworkManager.conf

sudo chattr -i /etc/resolv.conf
sudo rm -f /etc/resolv.conf

#=== systemd-resolved ===
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved

sudo systemctl status pihole.service
