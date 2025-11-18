#!/bin/bash

SERVICE_NAME=regexdns.service
APP_DIR=/opt/regexdns
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}
USER_HOME=$(get_user_home)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Import functions
source "${SCRIPT_DIR}/../util.sh"
root_check


# Clean log files
rm "${USER_HOME}/regexdns.log"

# Reset the service
reset_service "${SERVICE_NAME}"

sudo cp ${SERVICE_NAME} ${SERVICE_PATH}


sudo rm -rf "$APP_DIR"
sudo mkdir -p "$APP_DIR"
sudo cp -r "${SCRIPT_DIR}/*" "$APP_DIR/"

create_venv "$APP_DIR"

sudo systemctl enable systemd-timesyncd --now

start_service "$SERVICE_NAME"


dns_port=5354
install_dnsmasq() {
    echo "[INFO] Installing dnsmasq..."

    if is_command apt; then
        sudo apt update
        sudo apt install -y dnsmasq

    elif is_command pacman; then
        sudo pacman -Sy --noconfirm dnsmasq

    elif is_command dnf; then
        sudo dnf install -y dnsmasq

    elif is_command yum; then
        sudo yum install -y dnsmasq

    else
        echo "[ERROR] Unsupported package manager"
        exit 1
    fi
}

if ! is_command dnsmasq; then
    install_dnsmasq
else
    echo "[INFO] dnsmasq is already installed"
fi

disable_resolved

sudo mkdir -p /etc/dnsmasq.d
sudo tee /etc/dnsmasq.d/${dns_port}.conf > /dev/null <<EOF
port=${dns_port}
listen-address=127.0.0.1
bind-interfaces
EOF

# --- Restart dnsmasq ---
sudo systemctl restart dnsmasq
