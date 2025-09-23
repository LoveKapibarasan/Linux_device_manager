#!/bin/bash

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi
echo "Using home directory: $USER_HOME"

# 必要な引数チェック
MODE="$1"
if [ -z "$MODE" ]; then
    echo "Usage: $0 {middle|strict}"
    exit 1
fi

# Docker コンテナ名 (必要なら環境に合わせて変更)
CONTAINER_NAME="pihole"

DB_DIR="$USER_HOME/Linux_device_manager/white_list_3/db"
PIHOLE_DB="/etc/pihole/gravity.db"

# ファイル存在チェック
if [ ! -f "$DB_DIR/gravity_black.db" ]; then
  echo "Error: $DB_DIR/gravity_black.db not found."
  exit 1
fi
if [ ! -f "$DB_DIR/gravity_current.db" ]; then
  echo "Error: $DB_DIR/gravity_current.db not found."
  exit 1
fi

case "$MODE" in
  middle)
    echo "[*] Switching to middle mode..."
    docker exec "$CONTAINER_NAME" mv "$PIHOLE_DB" "$PIHOLE_DB.bak"
    docker cp "$DB_DIR/gravity_black.db" "$CONTAINER_NAME:$PIHOLE_DB"
    docker exec "$CONTAINER_NAME" pihole -g
    ;;
  strict)
    echo "[*] Switching to strict mode..."
    docker exec "$CONTAINER_NAME" mv "$PIHOLE_DB" "$PIHOLE_DB.bak"
    docker cp "$DB_DIR/gravity_current.db" "$CONTAINER_NAME:$PIHOLE_DB"
    docker exec "$CONTAINER_NAME" pihole -g
    ;;
  *)
    echo "Usage: $0 {middle|strict}"
    exit 1
    ;;
esac
