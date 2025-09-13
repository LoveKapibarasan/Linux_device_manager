#!/bin/bash

MODE="$1"
DB_DIR="$HOME/Linux_device_manager/white_list_3/db"
PIHOLE_DB="/etc/pihole/gravity.db"

# Import functions
. ../util.sh

root_check

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
