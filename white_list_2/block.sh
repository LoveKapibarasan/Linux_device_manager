#!/bin/bash
# ===============================================
# block_list.csv の URL/ドメイン → IP解決 → ipset/iptables で全ポートブロック
# ===============================================

set -e

if [[ $EUID -ne 0 ]]; then
    echo "このスクリプトは sudo または root で実行してください"
    exit 1
fi

CSV_FILE="./block_list.csv"
IPSET_NAME="DOH_BLOCK"

if [[ ! -f $CSV_FILE ]]; then
    echo "CSVファイル $CSV_FILE が見つかりません"
    exit 1
fi

echo "[0/4] 既存 ipset と iptables ルールを初期化しています..."

# ipset 初期化
ipset destroy "$IPSET_NAME" 2>/dev/null || true
ipset create "$IPSET_NAME" hash:ip -exist

# iptables OUTPUT チェーンから当該DROPルール削除
while iptables -C OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP 2>/dev/null; do
    iptables -D OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP
done

echo "[1/4] block_list.csv から IP解決してブロック追加..."

while read -r raw; do
    # 空行・コメント行を無視
    [[ -z "$raw" || "$raw" =~ ^# ]] && continue

    # URL形式 → ドメイン名だけ抽出
    # 1) https://やhttp://を除去, 2) /以降をカット
    domain=$(echo "$raw" | sed -e 's~^[a-zA-Z]*://~~' -e 's~/.*~~')

    echo " - $domain"

    # Aレコード解決
    ips=$(dig +short "$domain" A | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)

    if [[ -z "$ips" ]]; then
        echo "   → IP解決できずスキップ"
        continue
    fi

    for ip in $ips; do
        echo "   → add $ip"
        ipset add "$IPSET_NAME" "$ip" -exist
    done
done < "$CSV_FILE"

echo "[2/4] iptables に DROPルール追加（全ポート）..."
iptables -A OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP

echo "[3/4] 現在ブロックされているIP:"
ipset list "$IPSET_NAME"

echo "[4/4] 完了しました ✅"
