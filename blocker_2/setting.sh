#!/bin/bash

# Path declarations
SERVICE_NAME=shutdown-cui.service
APP_DIR=/opt/shutdown_cui
APP_PATH=${APP_DIR}/shutdown_cui.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}
USER_HOME=$(get_user_home)

# Import functions
source ../util.sh
root_check


# Reset the service
reset_service "${SERVICE_NAME}"

# Clean log files
rm "${USER_HOME}/notify.log"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}


sudo rm -rf "$APP_DIR"
sudo mkdir -p "$APP_DIR"
sudo cp -r . "$APP_DIR/"

create_venv "$APP_DIR"



cd "$APP_DIR"

sudo systemctl enable systemd-timesyncd --now   

start_service "$SERVICE_NAME"
