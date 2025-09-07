#!/bin/bash
# /opt /etc are safe.
# Path declarations
SERVICE_NAME=shutdown-cui.service
APP_DIR=/opt/shutdown_cui
APP_PATH=${APP_DIR}/shutdown_cui.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../util.sh

# Reset the service
reset_system "${SERVICE_NAME}"

# Reset /root/shutdown_cui/usage_file.json
sudo rm -f "/root/shutdown_cui/usage_file.json"

# Clean log files
clean_logs "notify.log"


sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"

create_venv "$APP_DIR"

start_service "$SERVICE_NAME"

sudo chmod 700 "$APP_DIR"