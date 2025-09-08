#!/bin/bash
SERVICE_NAME=patrol.service
APP_DIR=/opt/patrol
APP_PATH=${APP_DIR}/patrol
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# Import functions
. ../util.sh

# Reset the service
reset_system "${SERVICE_NAME}"

chmod +x delete.sh
sudo ./delete.sh

# Clean log files
clean_logs "patrol.log"


# Create profiles
cp ../white-list/_white-list.csv tmp
MARKER="/^#[[:space:]]*@[[:space:]]*@[[:space:]]*@/"
sed -n "$MARKER,$MARKER p" tmp > tmp2

filter_hash tmp2  profile_restricted.csv
filter_hash tmp  profile.csv

# compile
g++ patrol.cpp -o patrol

copy_files "$APP_DIR"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}

start_service "$SERVICE_NAME"

# Check
sudo cat /etc/regexhosts 