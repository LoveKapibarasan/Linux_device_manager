#!/bin/bash
BASENAME=pihole
SERVICE_NAME="${BASENAME}.service"
APP_DIR="/opt/${BASENAME}"
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
source ../util.sh

root_check

sudo ./delete_docker.sh

# Reset the service
reset_service "${SERVICE_NAME}"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"


start_service "$SERVICE_NAME"

# --- After setting up Pihole, change /etc/resolv.conf
sudo ./pihole_protect.sh

sudo ./generate_pass.sh

sudo chown -R 1000:1000 ./etc-pihole ./etc-dnsmasq.d

sudo docker logs -f pihole 

