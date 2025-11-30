#!/bin/bash
# /usr/local/bin/wg-reconnect.sh

DOMAIN="home.yourdomain.com"
WG_INTERFACE="wg0"
WG_CONFIG="/etc/wireguard/wg0.conf"
RESOLV_CONF="/etc/resolv.conf"
ENV_FILE="/etc/environment"
SERVER_IP='10.10.0.1'

# 環境変数から前回のIPを取得
LAST_IP=$(grep "^WG_ENDPOINT_IP=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2)

echo "$(date): Checking WireGuard endpoint status..."

# VPN経由でドメイン名を解決してみる
RESOLVED_IP=$(dig +short "$DOMAIN" @"$SERVER_IP" +timeout=3 2>/dev/null | head -n1)

# 解決できなかった場合は外部DNSで試す
if [ -z "$RESOLVED_IP" ]; then
    echo "$(date): Cannot resolve $DOMAIN via VPN DNS, trying external DNS..."
    RESOLVED_IP=$(dig +short "$DOMAIN" @1.1.1.1 +timeout=3 2>/dev/null | head -n1)

    if [ -z "$RESOLVED_IP" ]; then
        echo "$(date): ERROR - Cannot resolve $DOMAIN at all"
        exit 1
    fi

    NEED_RECONNECT=true
    REASON="VPN DNS resolution failed"
else
    # IPが変わったかチェック
    if [ "$RESOLVED_IP" != "$LAST_IP" ]; then
        NEED_RECONNECT=true
        REASON="IP changed from $LAST_IP to $RESOLVED_IP"
    else
        NEED_RECONNECT=false
    fi
fi

# 再接続が不要な場合は終了
if [ "$NEED_RECONNECT" != "true" ]; then
    echo "$(date): No reconnect needed. Current IP: $RESOLVED_IP"
    exit 0
fi

echo "$(date): Reconnect needed - $REASON"

# ========== ここから再接続処理 ==========

# 1. WireGuardを停止
echo "Stopping WireGuard..."
wg-quick down "$WG_INTERFACE" 2>/dev/null || true

# 2. resolv.confのimmutableを解除
echo "Unlocking /etc/resolv.conf..."
sudo chattr -i /etc/resolv.conf && sudo rm /etc/resolv.conf

# 3. 一時的に1.1.1.1を使用
echo "Setting temporary DNS to 1.1.1.1..."
cat > "$RESOLV_CONF" << EOF
nameserver 1.1.1.1
EOF

# 4. ドメインを名前解決
echo "Resolving $DOMAIN..."
CURRENT_IP=$(dig +short "$DOMAIN" @1.1.1.1 | head -n1)

if [ -z "$CURRENT_IP" ]; then
    echo "ERROR: Failed to resolve $DOMAIN"
    exit 1
fi

echo "Resolved IP: $CURRENT_IP"
sudo rm /etc/resolv.conf
cat > "$RESOLV_CONF" << EOF
nameserver $CURRENT_IP
EOF


# 5. /etc/environmentにIPとタイムスタンプを保存
sudo sed -i '/^WG_ENDPOINT_IP=/d' "$ENV_FILE"
sudo sed -i '/^WG_LAST_UPDATE=/d' "$ENV_FILE"
echo "WG_ENDPOINT_IP=$CURRENT_IP" | sudo tee -a "$ENV_FILE" > /dev/null
echo "WG_LAST_UPDATE=$(date -Iseconds)" | sudo tee -a "$ENV_FILE" > /dev/null

# 6. WireGuard設定ファイルのEndpointを更新
echo "Updating WireGuard config..."
sudo sed -i "s/^Endpoint = .*/Endpoint = $CURRENT_IP:51820/" "$WG_CONFIG"

# 7. WireGuardを起動
echo "Starting WireGuard..."
wg-quick up "$WG_INTERFACE"

# 8. 接続確認
sleep 2
if ping -c 1 "$SERVER_IP" &>/dev/null; then
    echo "$(date): WireGuard connected successfully to $CURRENT_IP"
else
    echo "$(date): WARNING - Cannot ping $SERVER_IP"
fi

echo "Locking /etc/resolv.conf..."
sudo chattr +i /etc/resolv.conf