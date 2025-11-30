#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -s "${SCRIPT_DIR}/.env" ]; then
	echo "no .env" && exit 1
fi
source "${SCRIPT_DIR}/.env"

# 前回のIPを取得（/etc/environmentから）
LAST_IP=$(grep "^DDNS_LAST_IP=" /etc/environment 2>/dev/null | cut -d'=' -f2)

# 現在のIPを取得
CURRENT_IP=$(curl -s https://api.ipify.org)

# IPが変わっていない場合は何もしない
if [ "$CURRENT_IP" = "$LAST_IP" ]; then
    echo "$(date): IP unchanged ($CURRENT_IP), skipping update"
    exit 0
fi

echo "$(date): IP changed from $LAST_IP to $CURRENT_IP, updating..."


ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  | jq -r '.result[0].id')

echo "Zone ID: $ZONE_ID"

RECORD_ID=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$RECORD_NAME" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  | jq -r '.result[0].id')

echo "Record ID: $RECORD_ID"


# DNSレコードを更新
RESPONSE=$(curl -s -X PUT \
  "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":false}")

# 成功したか確認
SUCCESS=$(echo $RESPONSE | jq -r '.success')

if [ "$SUCCESS" = "true" ]; then
    echo "$(date): Successfully updated $RECORD_NAME to $CURRENT_IP"

    # /etc/environmentに記録
    sudo sed -i '/^DDNS_LAST_IP=/d' /etc/environment
    echo "DDNS_LAST_IP=$CURRENT_IP" | sudo tee -a /etc/environment > /dev/null

    # 最終更新日時も記録
    sudo sed -i '/^DDNS_LAST_UPDATE=/d' /etc/environment
    echo "DDNS_LAST_UPDATE=$(date -Iseconds)" | sudo tee -a /etc/environment > /dev/null
else
    echo "$(date): Error updating DNS record"
    echo "$RESPONSE" | jq
fi