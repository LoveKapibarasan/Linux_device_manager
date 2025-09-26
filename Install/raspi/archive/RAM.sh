#!/bin/bash

# OOM ZRAM
sudo apt install earlyoom zram-tools -y

# stop swap 
sudo dphys-swapfile swapoff 

# 1. GB 単位で入力を受け取る
read -p "Swap size in GB(2~4): " gb

# 2. MB に変換
mb=$((gb * 1024))

# 3. /etc/dphys-swapfile の設定を更新 (CONF_SWAPSIZE)
sudo sed -i "s/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=$mb/" /etc/dphys-swapfile

# 4. もし 2GB (2048MB) を超えていたら CONF_MAXSWAP も更新
if [ "$mb" -gt 2048 ]; then
  # コメントアウトされている場合でも置換
  sudo sed -i "s/^#\?CONF_MAXSWAP=.*/CONF_MAXSWAP=$mb/" /etc/dphys-swapfile
  # 存在しない場合は追記
  grep -q '^CONF_MAXSWAP=' /etc/dphys-swapfile || echo "CONF_MAXSWAP=$mb" | sudo tee -a /etc/dphys-swapfile
fi

# 5. 反映して再起動
echo "Set swap size to ${mb} MB"
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
