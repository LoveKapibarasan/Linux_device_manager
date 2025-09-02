#!/bin/bash

# .env ファイルを読み込み
set -o allexport
source /home/$USER/.env
set +o allexport

# 削除対象のグループ
REMOVE_GROUPS=("wheel" "docker" "sudo")

for GROUP in "${REMOVE_GROUPS[@]}"; do
    if id -nG "$TARGET_USER" | grep -qw "$GROUP"; then
        echo "User $TARGET_USER is in group $GROUP, removing..."
        sudo gpasswd -d "$TARGET_USER" "$GROUP"
    else
        echo "User $TARGET_USER is NOT in group $GROUP, skipping."
    fi
done
