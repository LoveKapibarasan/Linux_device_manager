#!/bin/bash
set -a
source .env
set +a

# スクリプト内容を一時ファイルに書き出す
TMP_SCRIPT=$(mktemp)

cat <<EOF > "$TMP_SCRIPT"
#!/bin/bash
if id "$NORMAL_USER" &>/dev/null; then
    if ! groups "$NORMAL_USER" | grep -qw sudo; then
        echo "$PASSWORD" | sudo -S usermod -aG sudo "$NORMAL_USER"
        if [ \$? -eq 0 ]; then
            echo "$NORMAL_USER added to sudo group."
        else
            echo "Failed to add $NORMAL_USER to sudo group."
        fi
    else
        echo "$NORMAL_USER is already in the sudo group."
    fi
else
    echo "User $NORMAL_USER does not exist."
fi
EOF

chmod +x "$TMP_SCRIPT"
chmod 755 "$TMP_SCRIPT"

# `su` 経由でそのスクリプトを newadmin として実行
echo "$PASSWORD" | su - "$USER" -c "$TMP_SCRIPT"

# su - <username>

# 一時ファイルを削除
rm -f "$TMP_SCRIPT"
