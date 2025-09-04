#!/bin/sh

ZSHRC="$HOME/.zshrc"
ALIAS_CMD="alias chmodsh='find ~ -type f -name \"*.sh\" -exec chmod +x {} \;'"

# 既に定義されているか確認
if ! grep -q "alias chmodsh=" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "$ALIAS_CMD" >> "$ZSHRC"
    echo "✅ chmodsh alias を $ZSHRC に追加しました。"
else
    echo "ℹ️ chmodsh alias はすでに $ZSHRC にあります。"
fi