#!/bin/bash
# delete old

# setting up
sudo cp patrol.service /etc/systemd/system/patrol.service
sudo cp patrol.timer /etc/systemd/system/patrol.timer

mkdir -p /opt/patrol
sudo cp patrol.sh /opt/patrol/patrol.sh
sudo chmod +x /opt/patrol/patrol.sh

sudo systemctl daemon-reload
sudo systemctl enable patrol.timer
sudo systemctl start patrol.timer
