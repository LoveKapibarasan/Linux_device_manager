#!/bin/bash
# Import functions
. ../util.sh

root_check

sudo docker rm -f pihole

sudo rm -rf /etc/systemd/system/pihole.service
sudo rm -rf /opt/pihole
sudo systemctl disable pihole.service
sudo systemctl stop pihole.service

sudo ./delete.sh

sudo docker ps