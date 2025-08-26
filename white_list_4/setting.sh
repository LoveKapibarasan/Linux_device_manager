#!/bin/bash
# /opt /etc are safe.
# Path declarations
SERVICE_NAME=regexdns.service
APP_DIR=/opt/regexdns
APP_PATH=${APP_DIR}/regexdns.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../reset_system.sh
. ../copy_files.sh

# Reset the service
reset_system "${SERVICE_NAME}"

sudo cp §{SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"

create_venv "$APP_DIR"

start_service "$SERVICE_NAME"
