#!/bin/bash
# Import functions
. ../util.sh

root_check


sudo docker rm -f pihole
sudo docker ps

sudo rm -rf /opt/pihole

sudo ./delete.sh