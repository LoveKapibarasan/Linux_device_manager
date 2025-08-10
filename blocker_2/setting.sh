#!/bin/bash

# Path declarations
SERVICE_NAME=shutdown-cui.service
APP_DIR=/opt/shutdown_cui
APP_PATH=${APP_DIR}/shutdown_cui.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Check if the service is already running and remove
# Stop the running service
sudo systemctl stop ${SERVICE_NAME}

# Disable it so it doesn't start on boot
sudo systemctl disable ${SERVICE_NAME}

# Remove the unit file
sudo rm ${SERVICE_PATH}

sudo rm -f ${SERVICE_PATH}
sudo systemctl reset-failed ${SERVICE_NAME}
sudo rm -f /etc/systemd/system/multi-user.target.wants/${SERVICE_NAME}

# Reload systemd to forget the old unit
sudo systemctl daemon-reload
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

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

# install GUI app
sudo rm -r ${APP_DIR}
sudo mkdir -p ${APP_DIR}
sudo cp shutdown_cui.py ${APP_DIR}/
sudo cp block_manager.py ${APP_DIR}/
sudo cp utils.py ${APP_DIR}/
sudo cp requirements.txt ${APP_DIR}/
sudo cp .env ${APP_DIR}/

# make utils.py unreadable because it contains admin password
sudo chown root:root ${APP_DIR}/.env # Change ownership to root
sudo chmod 440 ${APP_DIR}/.env # Owner can read, no one else can read or write


# Create a virtual environment and install dependencies
sudo python3 -m venv ${APP_DIR}/venv
sudo ${APP_DIR}/venv/bin/pip install -r ${APP_DIR}/requirements.txt



# Start the service
sudo systemctl start "$SERVICE_NAME"
sudo systemctl enable "$SERVICE_NAME"


sudo apt update
# Install policykit-1 for polkit rules
sudo apt install policykit-1
sudo apt install polkitd pkexec


# Create polkit rule to allow shutdown without password

sudo mkdir -p /etc/polkit-1/rules.d

sudo cat > /etc/polkit-1/rules.d/49-power.rules <<  'EOF'
polkit.addRule(function(action, subject) {
    if (
        action.id == "org.freedesktop.login1.suspend" ||
        action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
        action.id == "org.freedesktop.login1.hibernate" ||
        action.id == "org.freedesktop.login1.reboot" ||
        action.id == "org.freedesktop.login1.power-off"
    ) {
        return polkit.Result.YES;
    }
});
EOF

sudo systemctl restart polkit

