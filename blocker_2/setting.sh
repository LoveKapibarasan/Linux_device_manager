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
. ../available_journal.sh
. ../disable_time.sh

# Reset the service
reset_system "${SERVICE_NAME}"

# Reset /root/shutdown_cui/usage_file.json
sudo rm -f "/root/shutdown_cui/usage_file.json"



sudo cat > ${SERVICE_PATH} <<  'EOF'
[Unit]
Description=Blocker_2

[Service]
ExecStart=/bin/bash -c 'source /opt/shutdown_cui/venv/bin/activate && exec /usr/bin/python3 /opt/shutdown_cui/shutdown_cui.py'
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

# install system dependencies
sudo apt update
sudo apt install -y python3 libnotify-bin

copy_files "$APP_DIR"


# make utils.py unreadable because it contains admin password
sudo chown root:root ${APP_DIR}/.env # Change ownership to root
sudo chmod 440 ${APP_DIR}/.env # Owner can read, no one else can read or write


create_venv "$APP_DIR"

available_journal
disable_time

start_service "$SERVICE_NAME"
