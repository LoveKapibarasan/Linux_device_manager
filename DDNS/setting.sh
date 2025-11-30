#!/bin/bash

# Cloudflare DDNS

# User API Tokens -> Edit zone DNS
## 1. Permissions
## 2. Zone Resources
## 3. Client IP Filtering: firewall
## 4. TTL(Time to Live): Start Date / End Date


BASE_NAME='ddns'
APP_DIR=/opt/DDNS
SERVICE_PATH="/etc/systemd/system/${BASE_NAME}"
USER_HOME=$(get_user_home)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Import functions
source "${SCRIPT_DIR}/../util.sh"
root_check

# Reset the service
reset_service "${BASE_NAME}.service"
reset_timer "${BASE_NAME}.timer"

sudo cp ${BASE_NAME} "/etc/systemd/system/${BASE_NAME}.service"


start_service "${BASE_NAME}.service"
start_timer "${BASE_NAME}.timer"