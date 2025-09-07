#!/bin/bash
# /opt /etc are safe.
# Path declarations
SERVICE_NAME=regexdns.service
APP_DIR=/opt/regexdns
APP_PATH=${APP_DIR}/regexdns.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../reset_system.sh
. ../copy_files.sh

# Reset the service
reset_system "${SERVICE_NAME}"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

copy_files "$APP_DIR"

create_venv "$APP_DIR"


sudo systemctl disable --now systemd-resolved

# Add port=5353 to /etc/dnsmasq.conf
sudo systemctl restart dnsmasq

# Use localhost as a DNS server
nmcli device modify wlan0 ipv4.dns 127.0.0.1
# ignore the DNS addresses sent by the Wi-Fi router (via DHCP).
nmcli device modify wlan0 ipv4.ignore-auto-dns yes
nmcli device modify wlan0 ipv6.ignore-auto-dns yes
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolv.conf'



start_service "$SERVICE_NAME"



