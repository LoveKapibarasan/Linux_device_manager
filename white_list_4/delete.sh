#!/bin/bash
SERVICE_NAME=regexdns.service
APP_DIR=/opt/regexdns
SERVICE_PATH=/etc/systemd/system/${SERVICE_NAME}

# 停止 & 無効化
sudo systemctl stop "$SERVICE_NAME"
sudo systemctl disable "$SERVICE_NAME"

# サービスファイル削除
sudo rm -f "$SERVICE_PATH"

# アプリケーションディレクトリ削除
sudo rm -rf "$APP_DIR"

# systemd 設定リロード
sudo systemctl daemon-reload
sudo systemctl reset-failed

# dnsmasq のポート設定を元に戻す（必要なら）
sudo sed -i '/^port=5353$/d' /etc/dnsmasq.conf
sudo systemctl restart dnsmasq

# systemd-resolved を再度有効化（元に戻す）
sudo systemctl enable --now systemd-resolved

# NetworkManager の DNS 設定をクリア
nmcli device modify wlan0 ipv4.dns ""
nmcli device modify wlan0 ipv4.ignore-auto-dns no
nmcli device modify wlan0 ipv6.ignore-auto-dns no

# resolv.conf を systemd-resolved 管理に戻す
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

echo "✅ ${SERVICE_NAME} と関連設定を完全に削除しました"
