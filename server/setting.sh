#!/bin/bash


# Import functions
. ../util.sh

BASE_NAME=wayvnc
SERVICE_NAME="${BASE_NAME}.service"

copy_user_service_files "$BASE_NAME" "$SERViCE_DIR"

reset_user_service "$SERVICE_NAME"
start_user_service "$SERVICE_NAME"
