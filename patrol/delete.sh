#!/bin/bash

# Import functions
. ../util.sh

# Old versions
sudo rm -rf /etc/systemd/system/patrol.service
sudo rm -rf /etc/systemd/system/patrol.timer

# Delete dir
sudo rm -rf /opt/patrol
sudo systemctl stop patrol
sudo systemctl disable patrol

clean_logs "patrol.log"