#!/bin/bash

# サービス名とアプリパスを明示的に定義
SERVICE_NAME=shutdown-cui.service
APP_PATH=/opt/shutdown_cui/shutdown_cui.py
# サービスファイル生成
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"
echo -e "\n生成中: $SERVICE_PATH"
cat <<EOF | sudo tee "$SERVICE_PATH" > /dev/null
[Unit]
Description=Shutdown CUI App (Protected Mode, root global)
After=multi-user.target
Wants=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $APP_PATH
Restart=always
RestartSec=3
StartLimitInterval=0
User=root
Group=root
Environment=HOME=/root
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
    cp /home/takanori/Linux_device_blocker/blocker2/shutdown_cui.py /opt/shutdown_cui/
    cp /home/takanori/Linux_device_blocker/blocker2/block_manager.py /opt/shutdown_cui/
    cp /home/takanori/Linux_device_blocker/blocker2/requirements.txt /opt/shutdown_cui/

echo -e "\nPythonパッケージをインストール中..."
pip3 install --break-system-packages -r /opt/shutdown_cui/requirements.txt

chown -R root:root /opt/shutdown_cui
chmod -R 755 /opt/shutdown_cui

# サービスを有効化・開始
echo -e "\nサービスを有効化中..."

# サービスを有効化・再起動・状態確認（rootサービスのみ）
echo -e "\nサービスを有効化・再起動中..."
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

echo -e "\n=== インストール完了 ==="
echo "サービス状態を確認中..."
systemctl status "$SERVICE_NAME" --no-pager | head -20


# allow suspend/shutdown for all users
sudo mkdir -p /etc/polkit-1/localauthority/50-local.d/
sudo tee /etc/polkit-1/localauthority/50-local.d/50-shutdown-cui.pkla > /dev/null <<'EOF'
[Allow suspend/shutdown for shutdown-cui users]
Identity=unix-user:*
Action=org.freedesktop.login1.suspend;org.freedesktop.login1.hibernate;org.freedesktop.login1.power-off;org.freedesktop.login1.reboot
ResultActive=yes
EOF

sudo systemctl restart polkit

# takanoriユーザーにパスワードなしでblock_manager.pyを実行許可
echo 'takanori ALL=(root) NOPASSWD: /usr/bin/python3 /opt/shutdown_cui/block_manager.py' | sudo tee -a /etc/sudoers