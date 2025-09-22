#!/bin/bash
# usage: ./toggle-autologin.sh on|off

UNIT_DIR=/etc/systemd/system/getty@tty1.service.d
OVERRIDE=$UNIT_DIR/override.conf

sudo mkdir -p $UNIT_DIR

hour=$(date +%H)

if [ "$hour" -ge 20 ] && [ "$hour" -lt 21 ]; then
    echo "Enabling autologin..."
    sudo cp ~/.config/getty-autologin.conf $OVERRIDE
    sudo systemctl daemon-reexec
    sudo reboot now
elif [ "$hour" -ge 0 ] && [ "$hour" -lt 1 ]; then
    echo "Disabling autologin..."
    sudo cp ~/.config/getty-normal.conf $OVERRIDE
    # Reload systemd 
    sudo systemctl daemon-reexec
    sudo shutdown now
else
    exit 1
fi



