#!/bin/bash
set -e

# ~/bin が無ければ作成
mkdir -p ~/bin

# gp.sh を ~/bin/gp にコピー
cp gp.sh ~/bin/gp

# 実行権限付与
chmod +x ~/bin/gp

# PATH を .zshrc に追記（重複チェック付き）
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
fi

echo "✅ gp command installed. Please run 'exec zsh' or restart terminal to apply."

