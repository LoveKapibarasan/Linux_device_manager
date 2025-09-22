#!/bin/bash


# Import functions
. ../util.sh

BASE_NAME=wayvnc
SERVICE_NAME="${BASE_NAME}.service"

copy_user_service_files "$BASE_NAME" "$SERViCE_DIR"

reset_user_service "$SERVICE_NAME"
start_user_service "$SERVICE_NAME"


chmod 600 ~/.vncpasswd
#!/bin/bash

CONFIG_DIR="$HOME/.config/wayvnc"
CONFIG_FILE="$CONFIG_DIR/config"


mkdir -p "$HOME/.config/wayvnc"
# ユーザー入力を受け取る
read -p "VNC username: " VNCUSER
read -s -p "VNC password: " VNCPASS
echo
read -p "Port (default 5901): " VNCPORT
VNCPORT=${VNCPORT:-5901}

# 設定ファイルを作成
tee "$CONFIG_FILE" > /dev/null <<EOF
address=0.0.0.0
port=$VNCPORT

enable_auth=true
username=$VNCUSER
password=$VNCPASS

# TLS を使うなら以下を設定
#certificate_file=$CONFIG_DIR/cert.pem
#private_key_file=$CONFIG_DIR/key.pem
EOF

echo "WayVNC config saved to $CONFIG_FILE"

mkdir -p "$CONFIG_DIR"

