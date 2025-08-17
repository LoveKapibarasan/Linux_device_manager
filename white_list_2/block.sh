#!/bin/bash
set -e
if [[ $EUID -ne 0 ]]; then echo "rootで実行してください"; exit 1; fi
CSV_FILE="./block_list.csv"; IPSET_NAME="DOH_BLOCK"
HOSTS_FILE="/etc/hosts"; BEGIN="# --- DOH_BLOCK BEGIN ---"; END="# --- DOH_BLOCK END ---"
[ ! -f "$CSV_FILE" ] && echo "CSVなし" && exit 1
# init
ipset destroy "$IPSET_NAME" 2>/dev/null || true
ipset create "$IPSET_NAME" hash:ip -exist
while iptables -C OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP 2>/dev/null; do iptables -D OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP; done
# hosts block
sed -i "/${BEGIN}/,/${END}/d" "$HOSTS_FILE"
echo "$BEGIN" >> "$HOSTS_FILE"
while read -r raw; do [[ -z "$raw" || "$raw" =~ ^# ]] && continue; domain=$(echo "$raw"|sed 's~^[a-zA-Z]*://~~;s~/.*~~'); echo "0.0.0.0 $domain" >> "$HOSTS_FILE"; echo "::1 $domain" >> "$HOSTS_FILE"; done < "$CSV_FILE"
echo "$END" >> "$HOSTS_FILE"
# ipset
while read -r raw; do [[ -z "$raw"|| "$raw" =~ ^# ]]&&continue; domain=$(echo "$raw"|sed 's~^[a-zA-Z]*://~~;s~/.*~~'); ips=$(dig +short "$domain"|grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'); for ip in $ips; do ipset add "$IPSET_NAME" "$ip" -exist; done; done < "$CSV_FILE"
iptables -A OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP
echo "done"; ipset list "$IPSET_NAME"
