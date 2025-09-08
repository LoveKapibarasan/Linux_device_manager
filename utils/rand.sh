#!/bin/bash

ZSHRC="$HOME/.zshrc"

# すでに rand 関数が定義されているか確認
if ! grep -q "rand()" "$ZSHRC"; then
  cat >> "$ZSHRC" <<EOF

# rand 関数: 半角英数字のみかどうかを引数で切り替え
rand() {
  local length="\${1:-16}"     # 第1引数: 長さ (デフォルト16)
  local mode="\${2:-y}"        # 第2引数: y=英数字のみ, n=記号含む (デフォルトy)

  if [[ "\$mode" == "y" ]]; then
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "\$length"
  else
    tr -dc 'A-Za-z0-9!@#$%^&*()_+=-[]{};:,.<>/?' < /dev/urandom | head -c "\$length"
  fi
  echo
}
EOF

  echo "✅ rand 関数を $ZSHRC に追加しました。"
else
  echo "ℹ️ すでに rand 関数が定義されています。"
fi
