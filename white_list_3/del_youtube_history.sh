#!/usr/bin/env bash
# delete_youtube_history.sh — Chrome履歴からYouTubeだけ削除

PROFILE_DIR="$HOME/.config/google-chrome/Default"
DB="$PROFILE_DIR/History"

if [ ! -f "$DB" ]; then
  echo "Chromeの履歴DBが見つかりません: $DB"
  exit 1
fi

echo "Chromeを完全に終了してください（すべてのウインドウを閉じる）"
read -p "続行してよろしいですか？ (y/N): " yn
[[ "$yn" != "y" ]] && exit 0

# sqlite3 コマンドが必要
sudo apt install sqlite3 -y

sqlite3 "$DB" <<EOF
DELETE FROM urls WHERE url LIKE '%youtube.com%';
DELETE FROM visits WHERE url IN (SELECT id FROM urls WHERE url LIKE '%youtube.com%');
VACUUM;
EOF

echo "YouTube履歴削除完了"
