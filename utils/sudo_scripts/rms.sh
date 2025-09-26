#!/bin/bash

# Define groups to remove
REMOVE_GROUPS=("wheel" "docker" "sudo")

# import
source ${USER_HOME}/Linux_device_manager/util.sh

# Check root
root_check

# Get all users except root
USERS=$(awk -F: '{print $1}' /etc/passwd | grep -v '^root$')

for USER in $USERS; do
    for GROUP in "${REMOVE_GROUPS[@]}"; do
        if id -nG "$USER" 2>/dev/null | grep -qw "$GROUP"; then
            echo "User $USER is in group $GROUP, removing..."
            gpasswd -d "$USER" "$GROUP"

            # Verify if the user was actually removed
            if id -nG "$USER" | grep -qw "$GROUP"; then
                echo "Error: Failed to remove $USER from $GROUP"
                exit 1
            else
                echo "Successfully removed $USER from $GROUP"
            fi
        fi
    done
done

