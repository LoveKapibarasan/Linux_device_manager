#!/bin/bash
# Usage: ./encrypt.sh <directory> <password>

DIR="$1"
PASS="$2"
ARCHIVE="${DIR}.tar.gz"
ENCRYPTED="${DIR}.enc"

if [ -z "$DIR" ] || [ -z "$PASS" ]; then
    echo "Usage: $0 <directory> <password>"
    exit 1
fi

# フォルダをまとめて暗号化
tar -czf - "$DIR" | openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:"$PASS" -out "$ENCRYPTED"

echo "Encrypted to $ENCRYPTED"
