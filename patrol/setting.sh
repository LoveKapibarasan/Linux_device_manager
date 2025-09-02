#!/bin/bash
cp patrol.service /etc/systemd/system/patrol.service
cp patrol.timer /etc/systemd/system/patrol.timer

mkdir -p /opt/patrol
cp patrol.sh /opt/patrol/patrol.sh
chmod +x /opt/patrol/patrol.sh

sudo systemctl daemon-reload
sudo systemctl enable patrol.timer
sudo systemctl start patrol.timer
