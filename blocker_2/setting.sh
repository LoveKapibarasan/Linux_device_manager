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

# Make journal files owned by 'users' group (or another group all accounts share)
sudo chgrp -R users /var/log/journal
sudo chmod -R g+r /var/log/journal

# Also change the default ACL so new logs inherit it
sudo setfacl -R -m g:users:r /var/log/journal
sudo setfacl -d -m g:users:r /var/log/journal


# Disable time change for all users

sudo mkdir -p /etc/polkit-1/localauthority/50-local.d
sudo cat >> /etc/polkit-1/localauthority/50-local.d/disable-time-change.pkla << 'EOF'
[Disable time change]
Identity=unix-user:*
Action=org.freedesktop.timedate1.set-time
ResultAny=no
ResultInactive=no
ResultActive=no
EOF

sudo cat >> /etc/polkit-1/rules.d/60-deny-time-change.rules << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.timedate1.set-time" ||
        action.id == "org.freedesktop.timedate1.set-timezone" ||
        action.id == "org.freedesktop.timedate1.set-ntp") {
        return polkit.Result.NO;
    }
});
EOF
