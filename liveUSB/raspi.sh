#!/bin/bash
set -e

# ==== デバイス確認 ====
echo "[*] 接続中のブロックデバイス一覧:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# ==== 入力を促す ====
read -rp "書き込み先デバイス (例: /dev/sdX): " DEVICE

# 入力が存在しない場合は中断
if [[ -z "$DEVICE" ]]; then
    echo "エラー: デバイスが指定されていません"
    exit 1
fi

# /dev/sda のようなブロックデバイスかどうか簡易チェック
if [[ ! -b "$DEVICE" ]]; then
    echo "エラー: $DEVICE はブロックデバイスではありません"
    exit 1
fi

WORKDIR=$(mktemp -d -p /tmp)
cd "$WORKDIR"

echo "[*] Raspberry Pi OS Lite (64-bit) 最新イメージ（公式 latest）取得中..."
IMG_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2025-05-13/2025-05-13-raspios-bookworm-arm64-lite.img.xz"

wget -O raspios.img.xz "$IMG_URL"

echo "[*] 展開中..."
# 環境に合わせて以下いずれかを使用
if command -v xz >/dev/null 2>&1; then
  xz -d raspios.img.xz
elif command -v 7z >/dev/null 2>&1; then
  7z x raspios.img.xz
else
  echo "エラー: 展開に必要な xz または 7z が見つかりません" >&2
  exit 1
fi

IMG_FILE=$(find . -maxdepth 1 -type f -name "*.img" | head -n1)

echo "[*] 書き込み開始 (10秒後: Ctrl+Cで中断可)"
sleep 10
sudo dd if="$IMG_FILE" of="$DEVICE" bs=4M status=progress conv=fsync

cd /
rm -rf "$WORKDIR"
echo "[*] 完了: $DEVICE に Raspberry Pi OS Lite が書き込まれました"
