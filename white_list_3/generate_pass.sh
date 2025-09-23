#!/bin/bash
set -e
source ../util.sh

# Ask if using Docker or standard Pi-hole
read -p "Are you using Docker to run Pi-hole? (y/n): " use_docker

sudo touch /opt/pihole/.env
# 1. Generate random password and save to .env
pw=$(openssl rand -base64 20)
echo "ADMIN_PASSWORD=$pw" | sudo tee /opt/pihole/.env > /dev/null
sudo chmod 600 /opt/pihole/.env
echo "[OK] New password saved to /opt/pihole/.env"

# 2. Backup
backup_to_usb /opt/pihole/.env

# 3. If not using Docker, delete .env and set password
if [[ "$use_docker" =~ ^[Nn]$ ]]; then
    sudo rm -f /opt/pihole/.env
    sudo pihole setpassword "$pw"
    echo "[OK] .env removed (Docker installation)"
else
    echo "[INFO] .env kept (non-Docker installation)"
fi

