#!/bin/bash

# Import functions
. ../util.sh
root_check

if is_command pihole; then
    sudo pihole uninstall
fi


#=== NetworkManager ===
sudo sed -i '/^\s*dns=none\s*$/d' /etc/NetworkManager/NetworkManager.conf
cat /etc/NetworkManager/NetworkManager.conf

disable_resolved