#!/bin/bash
set -a
source .env
set +a

# Remove $NORMAL_USER from sudo group
if id "$NORMAL_USER" &>/dev/null; then
    if groups "$NORMAL_USER" | grep -qw sudo; then
        echo "$NORMAL_PASSWORD" | sudo -S gpasswd -d "$NORMAL_USER" sudo
        if [ $? -eq 0 ]; then
            echo "$NORMAL_USER removed from sudo group."
        else
            echo "Failed to remove $NORMAL_USER from sudo group."
        fi
    else
        echo "$NORMAL_USER is not in the sudo group."
    fi
else
    echo "User $NORMAL_USER does not exist."
fi
