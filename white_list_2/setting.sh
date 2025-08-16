#!/bin/bash

# Path declarations
SERVICE_NAME=white-list.service
APP_DIR=/opt/white_list
APP_PATH=${APP_DIR}/white_list_2.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../reset_system.sh
. ../copy_files.sh
. ../available_journal.sh
. ../disable_time.sh


sudo apt-get update
sudo apt-get install -y dnsmasq ipset
# （systemd-resolved を使っているなら）dns を dnsmasq に向けるのはスクリプト側で実施済み


# Reset the service
reset_system "${SERVICE_NAME}"

sudo cat > ${SERVICE_PATH} <<  'EOF'
[Unit]
Description=white_list

[Service]
ExecStart=/bin/bash -c 'source /opt/white_list/venv/bin/activate && exec /usr/bin/python3 /opt/white_list/white_list_2.py'
Restart=on-abnormal
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

copy_files "$APP_DIR"
create_venv "$APP_DIR"

available_journal
disable_time

start_service "$SERVICE_NAME"


sudo ./block.sh


# for rasberry pi
sudo apt install dnsutils -y

sudo apt install systemd-resolved -y
sudo systemctl enable --now systemd-resolved

# 再起動
sudo systemctl restart dnsmasq












