#!/usr/bin/env bash

# .env の読み込み
set -a        # 以降 export 自動付与
. .env
set +a

# USER と PASSWORD がない場合は止める
if [ -z "$USER" ] || [ -z "$PASSWORD" ]; then
  echo "USER または PASSWORD が .env にありません" >&2
  exit 1
fi

# ユーザーが存在しなければ作成
if ! id "$USER" >/dev/null 2>&1; then
  sudo useradd -m "$USER"
  echo "${USER}:${PASSWORD}" | sudo chpasswd
fi

# sudo 権限を付与
sudo usermod -aG sudo "$USER"

echo "User $USER created and added to sudo group."
