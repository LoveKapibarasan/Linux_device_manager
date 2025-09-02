#!/usr/bin/env bash

sudo cp pihole.service /etc/systemd/system/

# === Protect pihole ===
sudo mkdir -p /opt/pihole
sudo chown root:root /opt/pihole
sudo chmod 700 /opt/pihole

sudo cp docker-compose.yml /opt/pihole/
sudo cp .env /opt/pihole
sudo systemctl daemon-reload
sudo systemctl enable --now pihole.service

systemctl status pihole.service