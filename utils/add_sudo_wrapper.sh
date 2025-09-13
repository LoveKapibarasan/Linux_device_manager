#!/bin/bash

# Import functions
. ../util.sh

root_check

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FUNCTIONS_DIR="$SCRIPT_DIR/scripts"
INSTALL_DIR="/usr/local/bin/sudo_scripts"

# Check if scripts directory exists
if [ ! -d "$FUNCTIONS_DIR" ]; then
  echo "Directory $FUNCTIONS_DIR not found"
  exit 1
fi

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
  echo "Creating $INSTALL_DIR ..."
  sudo mkdir -p "$INSTALL_DIR"
  sudo chmod 755 "$INSTALL_DIR"
fi

# Copy scripts into /usr/local/bin/sudo_scripts
for file in "$FUNCTIONS_DIR"/*.sh; do
  [ -e "$file" ] || continue   # skip if no .sh files
  name="$(basename "$file" .sh)"  # remove extension

  sudo cp "$file" "$INSTALL_DIR/$name"
  sudo chmod +x "$INSTALL_DIR/$name"
  echo "Installed $name -> $INSTALL_DIR/$name"
done

echo "Scripts installed. Run them as: sudo <scriptname>"
