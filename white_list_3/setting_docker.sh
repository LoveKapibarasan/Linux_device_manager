#!/bin/bash
BASENAME=pihole
SERVICE_NAME="${BASENAME}.service"
APP_DIR="/opt/${BASENAME}"
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../util.sh

root_check

sudo ./delete_docker.sh

# Reset the service
reset_service "${SERVICE_NAME}"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"

sudo ./pihole_protect.sh

start_service "$SERVICE_NAME"

sudo ./generate_pass.sh


sudo docker logs -f pihole 