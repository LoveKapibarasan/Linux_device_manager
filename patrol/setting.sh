#!/bin/bash

# Path declarations
SERVICE_NAME=patrol.service
APP_DIR=/opt/patrol
APP_PATH=${APP_DIR}/shutdown_cui.py
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../util.sh

root_check

# Example usage
USER_HOME=$(get_user_home)
echo "Using home directory: $USER_HOME"

## 700
HOME="$USER_HOME" ./700.sh

# Reset the service
reset_service "${SERVICE_NAME}"
