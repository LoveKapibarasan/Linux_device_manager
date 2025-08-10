#!/bin/bash
set -a
source .env
set +a

# Check if user exists
if id "$NORMAL_USER" &>/dev/null; then
    # Check sudo access before removal
    echo "Checking sudo access for $NORMAL_USER..."
    if sudo -l -U "$NORMAL_USER" &>/dev/null; then
        echo "$NORMAL_USER currently has sudo privileges."
    else
        echo "$NORMAL_USER does NOT currently have sudo privileges."
    fi

    # Remove from sudo group
    if groups "$NORMAL_USER" | grep -qw sudo; then
        echo "$NORMAL_PASSWORD" | sudo -S gpasswd -d "$NORMAL_USER" sudo
        if [ $? -eq 0 ]; then
            echo "$NORMAL_USER removed from sudo group."
        else
            echo "Failed to remove $NORMAL_USER from sudo group."

        fi
    else
        echo "$NORMAL_USER is not in the sudo group."
    # Clear sudo cache
    echo "Clearing sudo authentication cache..."
    echo "$NORMAL_PASSWORD" | sudo -S -k
    echo "Sudo cache cleared."
    fi
else
    echo "User $NORMAL_USER does not exist."
fi
