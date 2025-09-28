#!/bin/bash

# Import functions
. ../util.sh

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

disable_resolved
