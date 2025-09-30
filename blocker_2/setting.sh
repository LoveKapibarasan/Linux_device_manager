#!/bin/bash

# Path declarations
SERVICE_NAME=shutdown-cui.service
APP_DIR=/opt/shutdown_cui
APP_PATH=${APP_DIR}/shutdown_cui.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../util.sh
root_check




# Reset the service
reset_service "${SERVICE_NAME}"

# Clean log files
clean_logs "notify.log"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"

create_venv "$APP_DIR"



cd "$APP_DIR"

read -p "Do you want to shutdown at night? (y/N) " answer
if [[ "$answer" == "n" || "$answer" == "N" ]]; then
    # Delete 'shutdown_all()', 'suspend_all()'  in block_manager.py
    sed -i '/shutdown_all()/d' block_manager.py
    sed -i '/suspend_all()/d' block_manager.py
    echo "Updated block_manager.py"
else
    echo "No changes made."
fi
read -p "Can you use suspend? (y/N) " answer
if [[ "$answer" == "n" || "$answer" == "N" ]]; then
    # Delete kill_wms
    sed -i '/^[[:space:]]*kill_wms*/d' block_manager.py
else
    echo "No changes made."
fi

sudo systemctl enable systemd-timesyncd --now   

start_service "$SERVICE_NAME"
