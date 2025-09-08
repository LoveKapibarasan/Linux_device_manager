#!/bin/bash

# Import functions
. ../util.sh

# Delete dir
sudo rm -rf /opt/patrol
sudo systemctl stop patrol
sudo systemctl disable patrol

clean_logs "patrol.log"