#!/bin/bash
docker rm -f pihole

sudo rm -rf /etc/systemd/system/pihole.service
sudo rm -rf /opt/pihole
sudo systemctl disable pihole.service
sudo systemctl stop pihole.service

systemctl status pihole.service


# NetworkManager
sudo sed -i '/^\s*dns=none\s*$/d' /etc/NetworkManager/NetworkManager.conf
cat /etc/NetworkManager/NetworkManager.conf

sudo chattr -i /etc/resolv.conf
sudo rm -f /etc/resolv.conf

# systemd-resolved
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved