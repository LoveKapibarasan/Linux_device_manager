#!/bin/bash

BASE_NAME=autologin
SERVICE_NAME="${BASE_NAME}.service"
SERVICE_TIMER="${BASE_NAME}.timer"

# Import functions
. ../util.sh
USER_HOME=$(get_user_home)

# Reset the service
reset_user_service "${SERVICE_NAME}"
reset_user_timer "${SERVICE_TIMER}"

sudo mkdir -p /etc/sudoers.d
if [ ! -f /etc/sudoers.d/toggle-autologin ]; then
  echo 'takanori ALL=(ALL) NOPASSWD: /home/takanori/toggle-autologin.sh' | sudo tee /etc/sudoers.d/toggle-autologin > /dev/null
  sudo chmod 440 /etc/sudoers.d/toggle-autologin
fi

read -p "Enter username: " username

replace_vars getty-autologin.conf "$username"
replace_vars autologin.service "$username"


sudo touch /etc/systemd/system/getty@tty1.service.d/override.conf

cp getty-autologin.conf "$USER_HOME/.config/getty-autologin.conf"
cp getty-normal.conf "$USER_HOME/.config/getty-normal.conf"

cp toggle-autologin.sh "$USER_HOME/toggle-autologin.sh"

copy_user_service_files "$BASE_NAME" "$SERVICE_DIR"


# Start the service
start_user_service "${SERVICE_NAME}"
start_user_timer "${SERVICE_TIMER}"
