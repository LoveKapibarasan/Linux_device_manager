#!/bin/bash

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi
echo "Using home directory: $USER_HOME"

# import
source ${USER_HOME}/Linux_device_manager/util.sh

# Check root
root_check

MODE="$1"
if [ -z "$MODE" ]; then
    echo "Usage: $0 {middle|strict}"
    exit 1
fi

# 共通パス
DB_DIR="$USER_HOME/Linux_device_manager/white_list_3/db"
PIHOLE_DB="/etc/pihole/gravity.db"
CONTAINER_NAME="pihole"

# DB存在チェック
for f in gravity_black.db gravity_current.db; do
    if [ ! -f "$DB_DIR/$f" ]; then
        echo "Error: $DB_DIR/$f not found."
        exit 1
    fi
done

# === 実行環境を判定 ===
if is_command pihole; then
    ENVIRONMENT="local"
else
    ENVIRONMENT="docker"
fi
echo "[*] Detected environment: $ENVIRONMENT"

enable_resolved

# === 処理 ===
case "$MODE" in
  middle)
    echo "[*] Switching to middle mode..."
    if [ "$ENVIRONMENT" = "local" ]; then
        cp "$DB_DIR/gravity_black.db" "$PIHOLE_DB"
        pihole -g
    else
        docker cp "$DB_DIR/gravity_black.db" "$CONTAINER_NAME:$PIHOLE_DB"
        docker exec "$CONTAINER_NAME" pihole -g
    fi
    ;;
  strict)
    echo "[*] Switching to strict mode..."
    if [ "$ENVIRONMENT" = "local" ]; then
        cp "$DB_DIR/gravity_current.db" "$PIHOLE_DB"
        pihole -g
    else
        docker cp "$DB_DIR/gravity_current.db" "$CONTAINER_NAME:$PIHOLE_DB"
        docker exec "$CONTAINER_NAME" pihole -g
    fi
    ;;
  *)
    echo "Usage: $0 {middle|strict}"
    exit 1
    ;;
esac

disable_resolved
