#!/bin/bash

# Global Variables
SERVICE_DIR=$HOME/.config/systemd/user


is_command() {
  command -v "$1" >/dev/null 2>&1
}
# Functions
copy_files() {
    APP_DIR="$1"
    sudo rm -rf "$APP_DIR"
    sudo mkdir -p "$APP_DIR"
    sudo cp -r . "$APP_DIR/"
}

copy_user_service_files(){
    BASE_NAME="$1"
    SERVICE_DIR="$2"
    mkdir -p "$SERVICE_DIR"
    cp "${BASE_NAME}.service" "$SERVICE_DIR"
    if [[ ! -f "${BASE_NAME}.timer" ]]; then
        cp "${BASE_NAME}.timer" "$SERVICE_DIR"
    fi
}

reset_service() {
    SERVICE_NAME="$1"
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/$SERVICE_NAME"
    sudo rm -f "/etc/systemd/system/multi-user.target.wants/$SERVICE_NAME"
    sudo systemctl reset-failed "$SERVICE_NAME"
    sudo systemctl daemon-reload
    sudo systemctl daemon-reexec
}

start_service() {
    SERVICE_NAME="$1"
    sudo systemctl start "$SERVICE_NAME"
    sudo systemctl enable "$SERVICE_NAME"
    journalctl -u "$SERVICE_NAME" -f
}

reset_user_service() {
    SERVICE_NAME="$1"
    systemctl --user stop "$SERVICE_NAME"
    systemctl --user disable "$SERVICE_NAME"
    rm -f "$HOME/.config/systemd/user/$SERVICE_NAME"
    rm -f "$HOME/.config/systemd/user/multi-user.target.wants/$SERVICE_NAME"
    systemctl --user reset-failed "$SERVICE_NAME"
    systemctl --user daemon-reload
    systemctl --user daemon-reexec
}

start_user_service() {
    SERVICE_NAME="$1"
    systemctl --user enable --now "$SERVICE_NAME"
    systemctl --user status "$SERVICE_NAME" --no-pager
    echo "logs (follow mode):"
    journalctl --user -u "$SERVICE_NAME" -n 20 -f
}


reset_user_timer() {
    TIMER_NAME="$1" 
    systemctl --user stop "$TIMER_NAME"
    systemctl --user disable "$TIMER_NAME"
    rm -f "$HOME/.config/systemd/user/$TIMER_NAME"
    rm -f "$HOME/.config/systemd/user/timers.target.wants/$TIMER_NAME"
    systemctl --user reset-failed "$TIMER_NAME"
    systemctl --user daemon-reload
    systemctl --user daemon-reexec
}



start_user_timer() {
    TIMER_NAME="$1"
    systemctl --user enable --now "$TIMER_NAME"
    systemctl --user list-timers --all | grep "$TIMER_NAME"
    echo "📌 logs:"
    journalctl --user -u "${TIMER_NAME%.timer}.service" -n 20 -f
}

create_venv() {
    APP_DIR="$1"
    /usr/bin/python3 -m venv "$APP_DIR/venv"
    sudo "$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt"
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

allow_nopass() {
    local basename=$1
    local username=$2

    sudo mkdir -p /etc/sudoers.d
    if [ ! -f /etc/sudoers.d/toggle-autologin ]; then
        echo "${username} ALL=(ALL) NOPASSWD: /home/${username}/${basename}.sh" | sudo tee "/etc/sudoers.d/${basename}" > /dev/null
        sudo chmod 440 "/etc/sudoers.d/${basename}"
    fi
    USER_HOME=$(get_user_home)
    mkdir -p "$USER_HOME/service_scripts"
    cp "${basename}.sh" "$USER_HOME/service_scripts/${SCRIPT_NAME}.sh"
}


enable_resolved() {
  echo "[*] Enabling systemd-resolved..."
  sudo chattr -i /etc/resolv.conf 2>/dev/null
  sudo rm -f /etc/resolv.conf
  sudo systemctl enable systemd-resolved --now
  echo "[*] systemd-resolved enabled. Pi-hole setup can run now."
sudo tee /etc/resolv.conf >/dev/null <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    if ! is_command pihole; then
        docker exec -it pihole bash -c "echo -e 'nameserver 1.1.1.1\nnameserver 8.8.8.8' > /etc/resolv.conf"
    fi
  sudo cat /etc/resolv.conf
}

disable_resolved() {
  echo "[*] Disabling systemd-resolved and locking resolv.conf..."
  sudo systemctl disable systemd-resolved --now
  sudo rm -f /etc/resolv.conf
  echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf >/dev/null
  sudo chattr +i /etc/resolv.conf
  echo "[*] resolv.conf set to 127.0.0.1 and locked."
  sudo cat /etc/resolv.conf
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
