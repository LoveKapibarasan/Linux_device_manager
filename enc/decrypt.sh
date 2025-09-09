#!/bin/bash
# Usage: ./decrypt.sh <encrypted_file> <password> <output_dir>

ENCRYPTED="$1"
PASS="$2"
OUTPUT="$3"

if [ -z "$ENCRYPTED" ] || [ -z "$PASS" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <encrypted_file> <password> <output_dir>"
    exit 1
fi

mkdir -p "$OUTPUT"

# 復号して展開
openssl enc -d -aes-256-cbc -pbkdf2 -in "$ENCRYPTED" -pass pass:"$PASS" | tar -xzf - -C "$OUTPUT"

echo "Decrypted into $OUTPUT"
