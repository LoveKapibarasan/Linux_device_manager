#!/bin/bash

# Global Variables
SERVICE_DIR=$HOME/.config/systemd/user

NORMAL_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
export NORMAL_USER


is_command() {
  command -v "$1" >/dev/null 2>&1
}
# Functions
copy_files() {
    local APP_DIR="$1"
    sudo rm -rf "$APP_DIR"
    sudo mkdir -p "$APP_DIR"
    sudo cp -r . "$APP_DIR/"
}

copy_user_service_files(){
    local BASE_NAME="$1"
    local SERVICE_DIR="$2"
    mkdir -p "$SERVICE_DIR"
    cp "${BASE_NAME}.service" "$SERVICE_DIR"
    if [[ ! -f "${BASE_NAME}.timer" ]]; then
        cp "${BASE_NAME}.timer" "$SERVICE_DIR"
    fi
}

reset_service() {
    local SERVICE_NAME="$1"
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/multi-user.target.wants/$SERVICE_NAME"
    sudo systemctl reset-failed "$SERVICE_NAME"
    sudo systemctl daemon-reload
    sudo systemctl daemon-reexec
}

reset_timer() {
    local TIMER_NAME="$1"
    sudo systemctl stop "$TIMER_NAME"
    sudo systemctl disable "$TIMER_NAME"
    sudo rm -f "/etc/systemd/system/$TIMER_NAME"
    sudo rm -f "/etc/systemd/system/timers.target.wants/$TIMER_NAME"
    sudo systemctl reset-failed "$TIMER_NAME"
    sudo systemctl daemon-reload
}

start_service() {
    local SERVICE_NAME="$1"
    sudo systemctl enable --now "$SERVICE_NAME"
    echo "Service logs:"
    sudo journalctl -u "$SERVICE_NAME" -n 20 -f
}

start_timer() {
    local TIMER_NAME="$1"
    sudo systemctl enable --now "$TIMER_NAME"
    sudo systemctl list-timers --all | grep "$TIMER_NAME"
    echo "Timer logs:"
    sudo journalctl -u "${TIMER_NAME%.timer}.service" -n 20 -f
}

reset_user_service() {
    local SERVICE_NAME="$1"
    systemctl --user stop "$SERVICE_NAME"
    systemctl --user disable "$SERVICE_NAME"
    rm -f "$HOME/.config/systemd/user/$SERVICE_NAME"
    rm -f "$HOME/.config/systemd/user/multi-user.target.wants/$SERVICE_NAME"
    systemctl --user reset-failed "$SERVICE_NAME"
    systemctl --user daemon-reload
    systemctl --user daemon-reexec
}

reset_user_timer() {
    local TIMER_NAME="$1" 
    systemctl --user stop "$TIMER_NAME"
    systemctl --user disable "$TIMER_NAME"
    rm -f "$HOME/.config/systemd/user/$TIMER_NAME"
    rm -f "$HOME/.config/systemd/user/timers.target.wants/$TIMER_NAME"
    systemctl --user reset-failed "$TIMER_NAME"
    systemctl --user daemon-reload
    systemctl --user daemon-reexec
}

start_user_service() {
    local SERVICE_NAME="$1"
    systemctl --user enable --now "$SERVICE_NAME"
    echo "Service logs:"
    journalctl --user -u "$SERVICE_NAME" -n 20 -f
}

start_user_timer() {
    local TIMER_NAME="$1"
    systemctl --user enable --now "$TIMER_NAME"
    systemctl --user list-timers --all | grep "$TIMER_NAME"
    echo "Timer logs:"
    journalctl --user -u "${TIMER_NAME%.timer}.service" -n 20 -f
}

create_venv() {
    local APP_DIR="$1"
    /usr/bin/python3 -m venv "$APP_DIR/.venv"
    sudo "$APP_DIR/.venv/bin/pip" install -r "$APP_DIR/requirements.txt"
}

clean_logs() {
    if [ -z "$1" ]; then
        echo "Usage: clean_logs <logfile_name>"
        return 1
    fi

    local target_file="$1"

    for user in $(loginctl list-users --no-legend | awk '{print $2}'); do
        home=$(getent passwd "$user" | cut -d: -f6)
        logfile="$home/$target_file"

        if [ -f "$logfile" ]; then
            rm -f "$logfile"
            echo "Deleted $logfile"
        else
            echo "No $target_file for $user"
        fi
    done
}


filter_hash() {
    local infile="$1"
    local outfile="$2"
    grep -vE '^\s*#|^\s*$' "$infile" > "$outfile"
}

root_check(){
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root" >&2
        exit 1
    fi
}

non_root_check(){
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script must NOT be run as root" >&2
        exit 1
    fi
}

# Function to get the home directory of the user who invoked sudo
get_user_home() {
    if [ -n "$SUDO_USER" ]; then
        eval echo "~$SUDO_USER"
    else
        echo "$HOME"
    fi
}

replace_vars() {
    local basename=$1
    local username=$2
    sed "s|<USER>|$username|g" "${basename}.example" > "$basename"
}


enable_resolved() {
   sudo chattr -i /etc/resolv.conf 
  sudo rm -f /etc/resolv.conf
   sudo systemctl unmask systemd-resolved
  sudo systemctl enable systemd-resolved --now
sudo tee /etc/resolv.conf >/dev/null <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    if ! is_command pihole; then
        docker exec -it pihole bash -c "echo -e 'nameserver 1.1.1.1\nnameserver 8.8.8.8' > /etc/resolv.conf"
    fi
  sudo cat /etc/resolv.conf
  # NetworkManager 
  sudo sed -i '/^\s*dns=none\s*$/d' /etc/NetworkManager/NetworkManager.conf
  sudo cat /etc/NetworkManager/NetworkManager.conf
  sudo systemctl restart NetworkManager

}

disable_resolved() {
  # Socket activation of resolved	
  sudo systemctl mask systemd-resolved-varlink.socket
  sudo systemctl mask systemd-resolved-monitor.socket
  sudo systemctl stop systemd-resolved
  sudo systemctl disable systemd-resolved.service
  sudo systemctl mask systemd-resolved.service
  sudo mv /usr/lib/systemd/systemd-resolved /usr/lib/systemd/systemd-resolved.disabled
  # Symbolic Link from sysinit  
  ls -la /etc/systemd/system/sysinit.target.wants/ | grep resolved
  sudo rm /etc/systemd/system/sysinit.target.wants/systemd-resolved.service
  # etc nssconf.switch
  sudo sed -i 's/resolve \[!UNAVAIL=return\] //g' /etc/nsswitch.conf
  cat /etc/nsswitch.conf | grep hosts
  sudo systemctl mask dnsmasq
  sudo systemctl mask dhcpcd
  sudo chattr -i /etc/resolv.conf
  sudo rm -f /etc/resolv.conf
  echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf >/dev/null
  sudo chattr +i /etc/resolv.conf
  sudo cat /etc/resolv.conf
  # NetworkManager
if grep -q '^\[main\]' /etc/NetworkManager/NetworkManager.conf; then
  # main exist
  if grep -A1 '^\[main\]' /etc/NetworkManager/NetworkManager.conf | grep -q '^dns='; then
     sudo sed -i '/^\[main\]/,/^\[/{s/^dns=.*/dns=none/}' /etc/NetworkManager/NetworkManager.conf
  else
    sudo sed -i '/^\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf
  fi
else
  # No main section
  echo -e "[main]\ndns=none" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
fi
  sudo cat /etc/NetworkManager/NetworkManager.conf
  sudo systemctl restart NetworkManager
  # check
  sudo lsof -i :53
}

# ==== デバイス入力 & 確認関数 ====
select_device() {
    echo "[*] 接続中のブロックデバイス一覧:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

    read -rp "書き込み先デバイス (例: /dev/sdX): " DEVICE

    # 入力が空なら中断
    if [[ -z "$DEVICE" ]]; then
        echo "エラー: デバイスが指定されていません"
        return 1
    fi

    # ブロックデバイスか確認
    if [[ ! -b "$DEVICE" ]]; then
        echo "エラー: $DEVICE はブロックデバイスではありません"
        return 1
    fi

    export DEVICE
    echo "[OK] 使用するデバイス: $DEVICE"
}

select_source_device() {
    echo "[*] 接続中のブロックデバイス一覧:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

    read -rp "バックアップ元デバイスを入力してください (例: /dev/mmcblk0): " SRC_DEV

    # 入力が空なら中断
    if [[ -z "$SRC_DEV" ]]; then
        echo "エラー: デバイスが指定されていません"
        return 1
    fi

    # ブロックデバイスか確認
    if [[ ! -b "$SRC_DEV" ]]; then
        echo "エラー: $SRC_DEV はブロックデバイスではありません"
        return 1
    fi

    export SRC_DEV
    echo "[OK] 使用するソースデバイス: $SRC_DEV"
}


# ==== デバイス選択 & マウント抽象関数 ====
mount_device() {
    # デバイス選択
    select_device || return 1

    read -rp "一時マウント先を入力してください (例: /mnt/usb): " usbpath

    # デフォルト値
    if [[ -z "$usbpath" ]]; then
        usbpath="/mnt/usb"
    fi

    # 既にマウントされているか確認
    already_mounted=$(lsblk -o NAME,MOUNTPOINT -n | grep "$(basename "$DEVICE")" | awk '{print $2}')

    if [[ -n "$already_mounted" ]]; then
        echo "[INFO] $DEVICE は既に $already_mounted にマウントされています"
        final_mount="$already_mounted"
    else
        # マウントポイントが存在しなければ作成
        if [[ ! -d "$usbpath" ]]; then
            echo "[INFO] マウントポイント $usbpath を作成します"
            sudo mkdir -p "$usbpath"
        fi

        echo "[INFO] $DEVICE を $usbpath にマウントします..."
        sudo mount "$DEVICE" "$usbpath" || {
            echo "エラー: マウントに失敗しました"
            return 1
        }
        final_mount="$usbpath"
    fi

    export final_mount
    echo "[OK] マウントパス: $final_mount"
}

# ==== バックアップユーティリティ (引数対応版) ====
backup_to_usb() {
    # 第1引数: コピー元
    local src="$1"

    # デバイス選択とマウント
    mount_device || return 1

    # USB 内ディレクトリ指定
    read -rp "USB 内の保存ディレクトリ名を入力してください : " usbdir
    if [[ -z "$usbdir" ]]; then
        usbdir="backup_$(date +%Y%m%d_%H%M%S)"
        echo "[INFO] デフォルトディレクトリ $usbdir を使用します"
    fi
    fullpath="$final_mount/$usbdir"

    # ディレクトリ作成
    if [[ ! -d "$fullpath" ]]; then
        echo "[INFO] $fullpath を作成します ..."
        sudo mkdir -p "$fullpath"
    fi

    # コピー元が引数で未指定なら対話式で入力
    if [[ -z "$src" ]]; then
        read -rp "バックアップするファイルまたはディレクトリのパスを入力してください: " src
    fi

    # 入力チェック
    if [[ -z "$src" || ! -e "$src" ]]; then
        echo "エラー: コピー元 $src が存在しません"
        return 1
    fi

    # コピー先ファイル名（任意でリネーム可能）
    read -rp "保存するファイル名（空 Enter で元の名前を使用）: " newname
    if [[ -z "$newname" ]]; then
        newname="$(basename "$src")"
    fi

    # コピー実行
    echo "[INFO] $src を $fullpath/$newname にコピーします ..."
    sudo cp -r "$src" "$fullpath/$newname" || {
        echo "エラー: コピーに失敗しました"
        return 1
    }

    echo "[OK] バックアップ保存完了: $fullpath/$newname"

    # 自動アンマウント
    sudo umount "$usbpath"
    echo "[OK] USB をアンマウントしました ($usbpath)"
    
}


# 指定ディレクトリ以下の全リポジトリで remote origin を upstream にリネームする
origin_to_upstream() {
local BASE_DIR="$1"

find "$BASE_DIR" -type d -name ".git" | while read -r gitdir; do
  repo_dir="$(dirname "$gitdir")"
  echo "Processing: $repo_dir"

  cd "$repo_dir" || continue

  # remote origin があるか確認
  if git remote | grep -q "^origin$"; then
    echo "Renaming origin -> upstream"
    git remote rename origin upstream
  else
    echo "No origin found in $repo_dir"
  fi
done
}
