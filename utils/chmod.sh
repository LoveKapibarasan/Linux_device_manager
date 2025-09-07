#!/bin/sh

ZSHRC="$HOME/.zshrc"
ALIAS_CMD="alias chmodsh='find ~ -type f -name \"*.sh\" -exec chmod +x {} \;'"

# Already defined ?
if ! grep -q "alias chmodsh=" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "$ALIAS_CMD" >> "$ZSHRC"
    echo "chmodsh alias is added. $ZSHRC "
else
    echo "chmodsh alias already $ZSHRC exist."
fi