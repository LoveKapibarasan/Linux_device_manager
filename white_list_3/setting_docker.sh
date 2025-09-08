#!/bin/bash
SERVICE_NAME=pihole.service
APP_DIR=/opt/pihole
APP_PATH=${APP_DIR}/pihole.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../util.sh

root_check

sudo ./delete_docker.sh

# Reset the service
reset_system "${SERVICE_NAME}"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"

chmod +x protect_pihole.sh
sudo ./protect_pihole.sh
chmod +x generate_pass.sh
sudo ./generate_pass.sh

start_service "$SERVICE_NAME"

sudo ./pihole_protect.sh