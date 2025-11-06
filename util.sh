#!/bin/bash

# Global Variables
SERVICE_DIR=$HOME/.config/systemd/user

NORMAL_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
export NORMAL_USER


is_command() {
  command -v "$1" >/dev/null 2>&1
}

reset_service() {
    local SERVICE_NAME="$1"
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/multi-user.target.wants/$SERVICE_NAME"
    sudo systemctl reset-failed "$SERVICE_NAME"
    sudo systemctl daemon-reload
    sudo systemctl daemon-reexec
}

reset_timer() {
    local TIMER_NAME="$1"
    sudo systemctl stop "$TIMER_NAME"
    sudo systemctl disable "$TIMER_NAME"
    sudo rm -f "/etc/systemd/system/$TIMER_NAME"
    sudo rm -f "/etc/systemd/system/timers.target.wants/$TIMER_NAME"
    sudo systemctl reset-failed "$TIMER_NAME"
    sudo systemctl daemon-reload
}

start_service() {
    local SERVICE_NAME="$1"
    sudo systemctl enable --now "$SERVICE_NAME"
    echo "Service logs:"
    sudo journalctl -u "$SERVICE_NAME" -n 20 -f
}

start_timer() {
    local TIMER_NAME="$1"
    sudo systemctl enable --now "$TIMER_NAME"
    sudo systemctl list-timers --all | grep "$TIMER_NAME"
    echo "Timer logs:"
    sudo journalctl -u "${TIMER_NAME%.timer}.service" -n 20 -f
}

reset_user_service() {
    local SERVICE_NAME="$1"
    systemctl --user stop "$SERVICE_NAME"
    systemctl --user disable "$SERVICE_NAME"
    rm -f "$HOME/.config/systemd/user/$SERVICE_NAME"
    rm -f "$HOME/.config/systemd/user/multi-user.target.wants/$SERVICE_NAME"
    systemctl --user reset-failed "$SERVICE_NAME"
    systemctl --user daemon-reload
    systemctl --user daemon-reexec
}

reset_user_timer() {
    local TIMER_NAME="$1" 
    systemctl --user stop "$TIMER_NAME"
    systemctl --user disable "$TIMER_NAME"
    rm -f "$HOME/.config/systemd/user/$TIMER_NAME"
    rm -f "$HOME/.config/systemd/user/timers.target.wants/$TIMER_NAME"
    systemctl --user reset-failed "$TIMER_NAME"
    systemctl --user daemon-reload
    systemctl --user daemon-reexec
}

start_user_service() {
    local SERVICE_NAME="$1"
    systemctl --user enable --now "$SERVICE_NAME"
    echo "Service logs:"
    journalctl --user -u "$SERVICE_NAME" -n 20 -f
}

start_user_timer() {
    local TIMER_NAME="$1"
    systemctl --user enable --now "$TIMER_NAME"
    systemctl --user list-timers --all | grep "$TIMER_NAME"
    echo "Timer logs:"
    journalctl --user -u "${TIMER_NAME%.timer}.service" -n 20 -f
}

create_venv() {
    local APP_DIR="$1"
    /usr/bin/python3 -m venv "$APP_DIR/.venv"
    sudo "$APP_DIR/.venv/bin/pip" install -r "$APP_DIR/requirements.txt"
}

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

non_root_check(){
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script must NOT be run as root" >&2
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


enable_resolved() {
    sudo chattr -i /etc/resolv.conf && sudo rm -f /etc/resolv.conf
    sudo systemctl unmask systemd-resolved
    sudo systemctl enable systemd-resolved --now
    sudo tee /etc/resolv.conf >/dev/null <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    if ! is_command pihole; then
        docker exec -it pihole bash -c "echo -e 'nameserver 1.1.1.1\nnameserver 8.8.8.8' > /etc/resolv.conf"
    fi
    # Check
    sudo cat /etc/resolv.conf
    
    # NetworkManager 
    sudo sed -i '/^\s*dns=none\s*$/d' /etc/NetworkManager/NetworkManager.conf
    sudo cat /etc/NetworkManager/NetworkManager.conf
    sudo systemctl restart NetworkManager
}

disable_resolved() {
  # Socket activation of resolved	
  sudo systemctl mask systemd-resolved-varlink.socket
  sudo systemctl mask systemd-resolved-monitor.socket
  sudo systemctl mask systemd-resolved.service
  sudo systemctl mask dnsmasq
  sudo systemctl mask dhcpcd

  # Symbolic Link from sysinit  
  sudo rm /etc/systemd/system/sysinit.target.wants/systemd-resolved.service

  sudo chattr -i /etc/resolv.conf
  sudo rm -f /etc/resolv.conf
  echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf >/dev/null
  sudo chattr +i /etc/resolv.conf
  sudo cat /etc/resolv.conf
  # NetworkManager
    if grep -q '^\[main\]' /etc/NetworkManager/NetworkManager.conf; then
        # [main] exist
        if grep -A1 '^\[main\]' /etc/NetworkManager/NetworkManager.conf | grep -q '^dns='; then
            sudo sed -i '/^\[main\]/,/^\[/{s/^dns=.*/dns=none/}' /etc/NetworkManager/NetworkManager.conf
        else
            sudo sed -i '/^\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf
        fi
    else
        # No [main] section
        echo -e "[main]\ndns=none" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
    fi
    # Check
    sudo cat /etc/NetworkManager/NetworkManager.conf
    sudo systemctl restart NetworkManager
    sudo lsof -i :53
}

# 指定ディレクトリ以下の全リポジトリで remote origin を upstream にリネームする
origin_to_upstream() {
    local BASE_DIR="$1"

    find "$BASE_DIR" -type d -name ".git" | while read -r gitdir; do
    repo_dir="$(dirname "$gitdir")"
    echo "Processing: $repo_dir"

    cd "$repo_dir" || continue

    # remote origin があるか確認
    if git remote | grep -q "^origin$"; then
        echo "Renaming origin -> upstream"
        git remote rename origin upstream
    else
        echo "No origin found in $repo_dir"
    fi
    done
}
