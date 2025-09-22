#!/bin/bash

copy_files() {
    APP_DIR="$1"
    sudo rm -rf "$APP_DIR"
    sudo mkdir -p "$APP_DIR"
    sudo cp -r . "$APP_DIR/"
}


reset_service() {
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
    /usr/bin/python3 -m venv "$APP_DIR/venv"
    sudo "$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt"
}

start_service() {
    SERVICE_NAME="$1"
    sudo systemctl start "$SERVICE_NAME"
    sudo systemctl enable "$SERVICE_NAME"
    journalctl -u "$SERVICE_NAME" -f
}


#!/bin/bash

clean_logs() {
    if [ -z "$1" ]; then
        echo "Usage: clean_logs <logfile_name>"
        return 1
    fi

    local target_file="$1"

    for user in $(loginctl list-users --no-legend | awk '{print $2}'); do
        home=$(getent passwd "$user" | cut -d: -f6)
        logfile="$home/$target_file"

        if [ -f "$logfile" ]; then
            rm -f "$logfile"
            echo "Deleted $logfile"
        else
            echo "No $target_file for $user"
        fi
    done
}


filter_hash() {
    local infile="$1"
    local outfile="$2"
    grep -vE '^\s*#|^\s*$' "$infile" > "$outfile"
}

root_check(){
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root" >&2
        exit 1
    fi
}

# Function to get the home directory of the user who invoked sudo
get_user_home() {
    if [ -n "$SUDO_USER" ]; then
        eval echo "~$SUDO_USER"
    else
        echo "$HOME"
    fi
}

# Example usage
USER_HOME=$(get_user_home)
echo "Using home directory: $USER_HOME"
