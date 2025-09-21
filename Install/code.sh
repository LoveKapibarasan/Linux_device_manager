#!/bin/bash

sudo apt install wget gpg apt-transport-https -y

# 1. Microsoft の公開鍵を取得してバイナリ形式に変換
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null

# 2. リポジトリの設定ファイルを追加
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/repos/code stable main" \
| sudo tee /etc/apt/sources.list.d/vscode.list

# 3. パッケージリストを更新してから VS Code をインストール
sudo apt update
sudo apt install code
