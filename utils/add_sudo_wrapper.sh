#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Import functions
source "$SCRIPT_DIR/../util.sh"

root_check
USER_HOME=$(get_user_home)
ZSHRC="$USER_HOME/.zshrc"
FUNCTIONS_DIR="$SCRIPT_DIR/sudo_scripts"
INSTALL_DIR="/usr/local/bin/sudo_scripts"

# Check if scripts directory exists
if [ ! -d "$FUNCTIONS_DIR" ]; then
  echo "Directory $FUNCTIONS_DIR not found"
  exit 1
fi

# Create install directory
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo chmod 755 "$INSTALL_DIR"


# Copy scripts into /usr/local/bin/sudo_scripts
for file in "$FUNCTIONS_DIR"/*.sh; do
  [ -e "$file" ] || continue   # skip if no .sh files
  name="$(basename "$file" .sh)"  # remove extension

  sudo cp "$file" "$INSTALL_DIR/$name"
  sudo chmod +x "$INSTALL_DIR/$name"
  echo "Installed $name -> $INSTALL_DIR/$name"
done

# Create a symlink
sudo ln -s "${USER_HOME}/Linux_device_manager/util.sh" "${INSTALL_DIR}/util.sh"

# Add to PATH if not already there
if grep -q "$INSTALL_DIR" "$ZSHRC"; then
  echo "$INSTALL_DIR is already in PATH."
else
  echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$ZSHRC"
  echo "Added $INSTALL_DIR to PATH in $ZSHRC"
fi


# Ensure /usr/local/bin/sudo_scripts is in sudo secure_path
SUDOERS_FILE="/etc/sudoers"
TARGET_DIR="/usr/local/bin/sudo_scripts"

# Extract current secure_path line
current_path=$(sudo grep -E "^Defaults\s+secure_path=" "$SUDOERS_FILE" | sed -E 's/^Defaults\s+secure_path="([^"]+)"/\1/')

if echo "$current_path" | grep -q "$TARGET_DIR"; then
  echo "secure_path already contains $TARGET_DIR"
else
  echo "Adding $TARGET_DIR to secure_path ..."
  new_path="${current_path}:${TARGET_DIR}"

  # Backup first
  sudo cp "$SUDOERS_FILE" "$SUDOERS_FILE.bak"

  # Replace line
  sudo sed -i "s|^Defaults\s\+secure_path=.*|Defaults    secure_path=\"$new_path\"|" "$SUDOERS_FILE"

  # Validate syntax
  if sudo visudo -c >/dev/null 2>&1; then
    echo "secure_path updated successfully."
  else
    echo "Error in sudoers file, restoring backup!"
    sudo cp "$SUDOERS_FILE.bak" "$SUDOERS_FILE"
  fi
fi

