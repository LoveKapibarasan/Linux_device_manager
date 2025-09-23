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

read -p "Enter username: " username

SCRIPT_NAME=toggle-autologin 

allow_nopass "${SCRIPT_NAME}" "${username}"

replace_vars "getty-autologin.conf" "${username}"

sudo touch /etc/systemd/system/getty@tty1.service.d/override.conf

cp getty-autologin.conf "$USER_HOME/.config/getty-autologin.conf"
cp getty-normal.conf "$USER_HOME/.config/getty-normal.conf"


copy_user_service_files "$BASE_NAME" "$SERVICE_DIR"


# Start the service
start_user_service "${SERVICE_NAME}"
start_user_timer "${SERVICE_TIMER}"
