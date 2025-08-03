#!/bin/bash

# エラー時に停止
set -e

# root権限チェック
if [ "$EUID" -ne 0 ]; then
    echo "このスクリプトはroot権限で実行してください。"
    echo "使用方法: sudo $0"
    exit 1
fi

SERVICE_NAME="shutdown-cui.service"
APP_PATH="/opt/shutdown_cui/shutdown_cui.py"

ALL_USERS=$(awk -F: '($3>=1000 && $3<65534) {print $1}' /etc/passwd)
ALL_USERS+=" root"

for USERNAME in $ALL_USERS; do
  HOME_DIR=$(eval echo ~$USERNAME)
  XAUTH="$HOME_DIR/.Xauthority"
  USER_ID=$(id -u "$USERNAME")
  DBUS_PATH="/run/user/$USER_ID/bus"
  SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME%.service}-$USERNAME.service"

  read -r -d '' SERVICE_CONTENT <<EOF || true
[Unit]
Description=Shutdown CUI App for $USERNAME (Protected Mode)
After=multi-user.target
Wants=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $APP_PATH
Restart=always
RestartSec=3
StartLimitInterval=0
User=$USERNAME
Group=$USERNAME
Environment=HOME=$HOME_DIR
Environment=USER=$USERNAME
WorkingDirectory=/opt/shutdown_cui
StandardOutput=journal
StandardError=journal
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=30
SendSIGKILL=yes

[Install]
WantedBy=multi-user.target
EOF

  echo -e "\n生成中: $SERVICE_PATH"
  echo "$SERVICE_CONTENT" | tee "$SERVICE_PATH" > /dev/null

done

# systemdに反映
systemctl daemon-reexec
systemctl daemon-reload
echo -e "\n完了: 全ユーザー分のサービスを作成し、systemd を再読み込みしました。"

# install system dependencies
echo -e "\n依存関係をインストール中..."
apt update
apt install -y python3 libnotify-bin

# install GUI app
echo -e "\nGUIアプリをインストール中..."
mkdir -p /opt/shutdown_cui
cp /home/takanori/Linux_device_blocker/blocker2/shutdown_cui.py /opt/shutdown_cui/
cp /home/takanori/Linux_device_blocker/blocker2/block_manager.py /opt/shutdown_cui/
cp /home/takanori/Linux_device_blocker/blocker2/requirements.txt /opt/shutdown_cui/

echo -e "\nPythonパッケージをインストール中..."
pip3 install --break-system-packages -r /opt/shutdown_cui/requirements.txt

chown -R root:root /opt/shutdown_cui
chmod -R 755 /opt/shutdown_cui

# サービスを有効化・開始
echo -e "\nサービスを有効化中..."
for USERNAME in $ALL_USERS; do
  SERVICE_NAME_USER="shutdown-cui-$USERNAME.service"
  echo "有効化中: $SERVICE_NAME_USER"
  systemctl enable "$SERVICE_NAME_USER"
  systemctl start "$SERVICE_NAME_USER"
done

echo -e "\n=== インストール完了 ==="
echo "サービス状態を確認中..."
systemctl list-units --type=service --all | grep shutdown-cui

