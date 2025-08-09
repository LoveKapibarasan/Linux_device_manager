#!/bin/bash
set -a
source .env
set +a

# スクリプト内容を一時ファイルに書き出す
TMP_SCRIPT=$(mktemp)

cat <<EOF > "$TMP_SCRIPT"
#!/bin/bash
if id "$TARGET_USER" &>/dev/null; then
    if ! groups "$TARGET_USER" | grep -qw sudo; then
        echo "$ADMIN_PASS" | sudo -S usermod -aG sudo "$TARGET_USER"
        if [ \$? -eq 0 ]; then
            echo "$TARGET_USER added to sudo group."
        else
            echo "Failed to add $TARGET_USER to sudo group."
        fi
    else
        echo "$TARGET_USER is already in the sudo group."
    fi
else
    echo "User $TARGET_USER does not exist."
fi
EOF

chmod +x "$TMP_SCRIPT"
chmod 755 "$TMP_SCRIPT"

# `su` 経由でそのスクリプトを newadmin として実行
echo "$ADMIN_PASS" | su - "$ADMIN_USER" -c "$TMP_SCRIPT"

# 一時ファイルを削除
rm -f "$TMP_SCRIPT"
