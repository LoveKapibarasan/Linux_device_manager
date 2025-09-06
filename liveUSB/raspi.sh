#!/bin/bash
set -e

DEVICE="/dev/sda"   # lsblk で確認したmicroSDのデバイス

# !!=== This is 32 bit ===
# IMG_URL="https://downloads.raspberrypi.com/raspios_lite_armhf_latest"

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

# ===== パスワード入力 =====
read -s -p "Enter password for user 'pi': " PASSWORD
echo
read -s -p "Confirm password: " PASSWORD2
echo

if [ "$PASSWORD" != "$PASSWORD2" ]; then
    echo "Passwords do not match!"
    exit 1
fi

# ===== WiFi 入力 =====
read -p "Enter WiFi SSID: " WIFI_SSID
read -s -p "Enter WiFi password: " WIFI_PASS
echo
read -p "Enter WiFi country code (e.g., DE, JP, US): " WIFI_COUNTRY


# ===== イメージ書き込み =====
echo "[*] Raspberry Pi OS Lite イメージ取得中..."
wget -O raspios-lite.img.xz "$IMG_URL"
7z x raspios-lite.img.xz
IMG_FILE=$(ls *.img)


echo "[*] 書き込み開始 (10秒後)"
sleep 10
sudo dd if="$IMG_FILE" of="$DEVICE" bs=4M status=progress conv=fsync

echo "[*] 書き込み完了。パーティション再読込..."
sudo partprobe "$DEVICE"

BOOT_PART="${DEVICE}1"
MNT="/mnt/raspi-boot"
sudo mkdir -p "$MNT"
sudo mount "$BOOT_PART" "$MNT"

# ===== SSH 有効化 =====
sudo touch "$MNT/ssh"

# ===== ユーザー pi のパスワード設定 =====
HASHED_PASS=$(echo "pi:$PASSWORD" | openssl passwd -6 -stdin)
echo "$HASHED_PASS" | sudo tee "$MNT/userconf.txt" >/dev/null


# ===== WiFi 設定 =====
cat <<EOF | sudo tee "$MNT/wpa_supplicant.conf" >/dev/null
country=$WIFI_COUNTRY
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PASS"
}
EOF

# ===== 後処理 =====
sudo umount "$MNT"
echo "[*] microSD セットアップ完了！ Raspberry Pi に挿して起動してください。"
