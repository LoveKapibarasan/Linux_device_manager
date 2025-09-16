#!/bin/bash

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi
echo "Using home directory: $USER_HOME"

# Check if script is run with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo/root privileges."
    exit 1
fi

MODE="$1"
DB_DIR="$USER_HOME/Linux_device_manager/white_list_3/db"
PIHOLE_DB="/etc/pihole/gravity.db"

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
    sudo mv "$PIHOLE_DB" "$DB_DIR/gravity_current.db"
    sudo cp "$DB_DIR/gravity_black.db" "$PIHOLE_DB"
    sudo pihole -g
    ;;
  strict)
    echo "[*] Switching to strict mode..."
    sudo mv "$PIHOLE_DB" "$DB_DIR/gravity_black.db"
    sudo cp "$DB_DIR/gravity_current.db" "$PIHOLE_DB"
    sudo pihole -g
    ;;
  *)
    echo "Usage: $0 {middle|strict}"
    exit 1
    ;;
esac
