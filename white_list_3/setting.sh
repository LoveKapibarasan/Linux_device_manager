#!/bin/bash

# Path declarations
SERVICE_NAME=white-list.service
APP_DIR=/opt/white_list
APP_PATH=${APP_DIR}/white_list_2.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}


# Clean old one
sudo rm -r ${APP_DIR}
sudo mkdir -p ${APP_DIR}