#!/bin/bash
# ===============================================
# YouTube 全ブラウザ共通ブロックスクリプト (Linux)
# root権限でのみ編集可
# ===============================================

if [[ $EUID -ne 0 ]]; then
    echo "このスクリプトはsudoまたはrootで実行してください"
    exit 1
fi

# --- 1. /etc/hostsにYouTube関連ドメイン追加 ---
echo "[1/3] /etc/hosts に YouTube 関連ドメインを追加中..."
YOUTUBE_DOMAINS=(
    "youtube.com"
    "www.youtube.com"
    "m.youtube.com"
    "youtu.be"
    "ytimg.com"
    "googlevideo.com"
    "ggpht.com"
)

for domain in "${YOUTUBE_DOMAINS[@]}"; do
    grep -q "$domain" /etc/hosts || echo "0.0.0.0 $domain" >> /etc/hosts
done

# --- 2. DoHプロバイダのIPブロック ---
echo "[2/3] DoH プロバイダのIPをブロック中..."
ipset create DOH_BLOCK hash:ip -exist

# Cloudflare
ipset add DOH_BLOCK 104.18.32.47 -exist
ipset add DOH_BLOCK 104.18.39.21 -exist
ipset add DOH_BLOCK 1.1.1.1 -exist
ipset add DOH_BLOCK 1.0.0.1 -exist

# Google Public DNS
ipset add DOH_BLOCK 8.8.8.8 -exist
ipset add DOH_BLOCK 8.8.4.4 -exist

# iptablesルール適用（IPv4）
iptables -C OUTPUT -p tcp --dport 443 -m set --match-set DOH_BLOCK dst -j DROP 2>/dev/null || \
iptables -I OUTPUT 1 -p tcp --dport 443 -m set --match-set DOH_BLOCK dst -j DROP
iptables -C OUTPUT -p udp --dport 443 -m set --match-set DOH_BLOCK dst -j DROP 2>/dev/null || \
iptables -I OUTPUT 1 -p udp --dport 443 -m set --match-set DOH_BLOCK dst -j DROP

# --- 3. DNSキャッシュのクリア ---
echo "[3/3] DNSキャッシュをクリア中..."
systemctl restart systemd-resolved 2>/dev/null
resolvectl flush-caches 2>/dev/null

echo "✅ YouTube ブロック設定が完了しました！"
