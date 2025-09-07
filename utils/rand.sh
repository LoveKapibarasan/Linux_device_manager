#!/bin/sh

ZSHRC="$HOME/.zshrc"
FUNC_NAME="rand"
FUNC_CMD='rand() { local length=${1:-16}; openssl rand -base64 $((length * 2)) | head -c "$length"; }'

# すでに定義されているかチェック
if ! grep -q "$FUNC_NAME()" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "$FUNC_CMD" >> "$ZSHRC"
    echo "rand function is added. $ZSHRC"
else
    echo "rand function already exists in $ZSHRC."
fi
