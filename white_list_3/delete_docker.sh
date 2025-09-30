#!/bin/bash

# Import functions
. ../util.sh

root_check

# Delete container
sudo docker rm -f pihole
# Delete pulled image
sudo docker rm pihole/pihole:latest
# Delete Volume


sudo docker ps

sudo rm -rf /opt/pihole

sudo ./delete.sh
