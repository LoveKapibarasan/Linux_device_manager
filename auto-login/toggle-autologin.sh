#!/bin/bash
# usage: ./toggle-autologin.sh on|off

UNIT_DIR=/etc/systemd/system/getty@tty1.service.d
OVERRIDE=$UNIT_DIR/override.conf

 mkdir -p $UNIT_DIR

hour=$(date +%H)

if [ "$hour" -ge 20 ] && [ "$hour" -lt 22 ]; then
    echo "Enabling autologin..."
     cp ~/.config/getty-autologin.conf $OVERRIDE
     systemctl daemon-reexec
     reboot now
elif [ "$hour" -ge 0 ] && [ "$hour" -lt 1 ]; then
    echo "Disabling autologin..."
     cp ~/.config/getty-normal.conf $OVERRIDE
    # Reload systemd 
     systemctl daemon-reexec
     shutdown now
else
    exit 1
fi




