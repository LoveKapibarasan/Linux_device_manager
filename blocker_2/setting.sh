#!/bin/bash

SERVICE_NAME=shutdown-cui.service
APP_DIR=/opt/shutdown-cui
USER_HOME=$(get_user_home)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Import functions
source "${SCRIPT_DIR}/../util.sh"
root_check

#TODO remove this
sudo rm -rf /opt/shutdown_cui

# Reset the service
reset_service "${SERVICE_NAME}"

# Clean log files
rm "${USER_HOME}/notify.log"

sudo cp ${SERVICE_NAME} "/etc/systemd/system/${SERVICE_NAME}"

sudo rm -rf "$APP_DIR"
sudo mkdir -p "$APP_DIR"
sudo cp -r "${SCRIPT_DIR}/*" "$APP_DIR/"

create_venv "$APP_DIR"

sudo systemctl enable systemd-timesyncd --now   

start_service "$SERVICE_NAME"
