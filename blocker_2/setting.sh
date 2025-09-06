#!/bin/bash
# /opt /etc are safe.
# Path declarations
SERVICE_NAME=shutdown-cui.service
APP_DIR=/opt/shutdown_cui
APP_PATH=${APP_DIR}/shutdown_cui.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../reset_system.sh
. ../copy_files.sh

# Reset the service
reset_system "${SERVICE_NAME}"

# Reset /root/shutdown_cui/usage_file.json
sudo rm -f "/root/shutdown_cui/usage_file.json"

# Clean log files
for user in $(loginctl list-users --no-legend | awk '{print $2}'); do
    home=$(getent passwd "$user" | cut -d: -f6)
    logfile="$home/notify.log"

    if [ -f "$logfile" ]; then
        rm -f "$logfile"
        echo "Deleted $logfile"
    else
        echo "No notify.log for $user"
    fi
done


sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"

create_venv "$APP_DIR"

start_service "$SERVICE_NAME"
