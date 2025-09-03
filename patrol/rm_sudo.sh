#!/bin/bash

# このスクリプト自身があるディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# .env を読み込み（rm_sudo.sh と同じディレクトリに置く）
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -o allexport
    source "$SCRIPT_DIR/.env"
    set +o allexport
else
    echo "Error: $SCRIPT_DIR/.env not found"
    exit 1
fi

# .env に TARGET_USER を書いておく
# 例: TARGET_USER=takanori

REMOVE_GROUPS=("wheel" "docker" "sudo")

for GROUP in "${REMOVE_GROUPS[@]}"; do
    if id -nG "$TARGET_USER" | grep -qw "$GROUP"; then
        echo "User $TARGET_USER is in group $GROUP, removing..."
        sudo gpasswd -d "$TARGET_USER" "$GROUP"
    fi
done

