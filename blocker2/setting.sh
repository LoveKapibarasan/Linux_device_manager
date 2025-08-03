#!/bin/bash

# システム上の全ユーザーを対象にサービスファイルを生成
SERVICE_NAME="shutdown-gui.service"
APP_PATH="/opt/shutdown_gui/shutdown_gui.py"

# /etc/systemd/system に一括配置するルートサービス（ログインユーザーで起動）
ALL_USERS=$(awk -F: '($3>=1000 && $3<65534) {print $1}' /etc/passwd)
ALL_USERS+=" root"

for USERNAME in $ALL_USERS; do
  HOME_DIR=$(eval echo ~$USERNAME)
  XAUTH="$HOME_DIR/.Xauthority"
  SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME%.service}-$USERNAME.service"

  read -r -d '' SERVICE_CONTENT <<EOF
[Unit]
Description=Shutdown GUI App for $USERNAME
After=graphical.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $APP_PATH
Restart=on-failure
User=$USERNAME
Environment=DISPLAY=:0
Environment=XAUTHORITY=$XAUTH
ProtectControlGroups=yes
KillMode=none

[Install]
WantedBy=graphical.target
EOF

  echo "\n生成中: $SERVICE_PATH"
  echo "$SERVICE_CONTENT" | sudo tee "$SERVICE_PATH" > /dev/null

done

sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "\n完了: 全ユーザー分のサービスを作成し、systemd を再読み込みしました。"


# install system dependencies
apt update
apt install -y python3-gi gir1.2-gtk-3.0 gir1.2-notify-0.7

# install python dependencies
pip3 install -r /opt/shutdown_gui/requirements.txt# install dependencies
sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-notify-0.7


# install GUI app
mkdir -p /opt/shutdown_gui
cp shutdown_gui.py block_manager.py requirements.txt /opt/shutdown_gui

sudo chown -R root:root /opt/shutdown_gui
sudo chmod -R 755 /opt/shutdown_gui
journalctl -u shutdown-gui.service

