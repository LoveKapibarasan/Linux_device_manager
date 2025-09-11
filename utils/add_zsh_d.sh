#!/bin/bash
set -e


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/zsh-d"
DST="$HOME/.zshrc.d"

# コピー先ディレクトリを作成（なければ）
mkdir -p "$DST"

# zsh ファイルをコピー
for file in "$SRC"/*.zsh; do
    [ -e "$file" ] || continue  # ファイルがない場合はスキップ
    base=$(basename "$file")
    cp "$file" "$DST/$base"
    echo "Copied: $file -> $DST/$base"
done

echo "Done! All .zsh files copied to $DST"
