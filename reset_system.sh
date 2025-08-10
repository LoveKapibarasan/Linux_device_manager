#!/bin/bash

reset_system() {
    SERVICE_NAME="$1"
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/multi-user.target.wants/$SERVICE_NAME"
    sudo systemctl reset-failed "$SERVICE_NAME"
    sudo systemctl daemon-reload
    sudo systemctl daemon-reexec
}

create_venv() {
    APP_DIR="$1"
    sudo python3 -m venv "$APP_DIR/venv"
    sudo "$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt"
}

start_service() {
    SERVICE_NAME="$1"
    sudo systemctl start "$SERVICE_NAME"
    sudo systemctl enable "$SERVICE_NAME"
    journalctl -u "$SERVICE_NAME" -f
}
