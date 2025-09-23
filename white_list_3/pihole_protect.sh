#!/bin/bash

ls -l /etc/resolv.conf 

sudo rm /etc/resolv.conf
sudo touch /etc/resolv.conf
# only 'nameserver 127.0.0.1' is best
sudo echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf

#=== NetworkManager ===
# 1.

if grep -q '^\[main\]' /etc/NetworkManager/NetworkManager.conf; then
  # [main] がある場合
  if grep -A1 '^\[main\]' /etc/NetworkManager/NetworkManager.conf | grep -q '^dns='; then
    sudo sed -i '/^\[main\]/,/^\[/{s/^dns=.*/dns=none/}' /etc/NetworkManager/NetworkManager.conf
  else
    sudo sed -i '/^\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf
  fi
else
  # [main] が無い場合
  echo -e "[main]\ndns=none" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
fi

sudo cat /etc/NetworkManager/NetworkManager.conf

# 2. make file immutable
sudo chattr +i /etc/resolv.conf

#=== resolved ===
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved


cd /opt/pihole

