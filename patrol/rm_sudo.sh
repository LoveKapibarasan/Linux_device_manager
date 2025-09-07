#!/bin/bash

REMOVE_GROUPS=("wheel" "docker" "sudo")

# /etc/passwd から全ユーザーを列挙して root を除外
USERS=$(awk -F: '{print $1}' /etc/passwd | grep -v '^root$')

for USER in $USERS; do
    for GROUP in "${REMOVE_GROUPS[@]}"; do
        if id -nG "$USER" 2>/dev/null | grep -qw "$GROUP"; then
            echo "User $USER is in group $GROUP, removing..."
            sudo gpasswd -d "$USER" "$GROUP"
        fi
    done
done
