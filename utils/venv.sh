#!/bin/sh

ZSHRC="$HOME/.zshrc"

# 関数が既に定義されているか確認
if ! grep -q "function venvup()" "$ZSHRC"; then
    cat << 'EOF' >> "$ZSHRC"

function venvup() {
    if [ ! -d "venv" ] && [ -f "requirements.txt" ]; then
        python -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi
}
EOF
    echo "✅ venvup 関数を $ZSHRC に追加しました。"
else
    echo "ℹ️ venvup 関数はすでに $ZSHRC にあります。"
fi
# source ~/.zshrc
