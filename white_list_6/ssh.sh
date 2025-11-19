#!/bin/bash

# .env
set -a
source .env
set +a

# Space
IPs=($IPS)

USERNAME=ubuntu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY_FILE=key.pem
KEY_PATH="${SCRIPT_DIR}/${KEY_FILE}"


for i in "${!IPs[@]}"; do
    echo "$((i+1)): ${IPs[$i]}"
done


read -p "Enter the number: " num

if [[ "$num" =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#IPs[@]} )); then
    IP="${IPs[$((num-1))]}"
else
    echo "Invalid"
    exit 1
fi

# The header and footer are needed -----BEGIN RSA PRIVATE KEY-----
chmod 400 "${KEY_PATH}" 
ssh -v -i "${KEY_PATH}" "${USERNAME}@${IP}"

# Are you sure you want to continue connecting (yes)? 

# http://ip4:port/