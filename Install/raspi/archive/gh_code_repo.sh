#!/bin/bash

sudo apt install wget gpg apt-transport-https curl -y

## 1. code 公開鍵を取得
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null

## 2. リポジトリ追加
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/repos/code stable main" \
| sudo tee /etc/apt/sources.list.d/vscode.list

## 1. Github CLI 公開鍵を取得
# Download and add the GitHub CLI repository key
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg

sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

## 2. リポジトリ追加
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# 3. パッケージリストを更新
sudo apt update
sudo apt install code gh -y

# 4. Login
gh auth login
