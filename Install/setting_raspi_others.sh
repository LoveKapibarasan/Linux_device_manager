#!/bin/bash

#  FortClient
sudo apt install openfortivpn -y

echo "openfortivpn"
read -p "Username: " username
echo
read -p "Password: " password
echo

cat <<EOF | sudo tee -a /etc/openfortivpn/config > /dev/null
host = sslvpn.oth-regensburg.de
port = 443
realm = vpn-default
trusted-cert = 364fb4fa107e591626b3919f0e7f8169e9d2097974f3e3d55e56c7c756a1f94a
username = $username
password = $password
EOF



# Graphics
sudo apt install -y mesa-utils mesa-vulkan-drivers vulkan-tools



# Electron
sudo apt install -y libfuse2 

#  2FA
# sudo apt install -y oathtool

# pyenv
curl https://pyenv.run | bash

sudo apt install -y \
    build-essential \
    libbz2-dev \
    libncurses5-dev libncursesw5-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    tk-dev \
    liblzma-dev \
    zlib1g-dev \
    libgdbm-dev \
    uuid-dev \
    libssl-dev

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
node -v



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


# 6. Tailscale SSH TigerVNC viewer
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable tailscaled
sudo systemctl start tailscaled
sudo tailscale up
sudo tailscale up --accept-dns=false

sudo apt install tigervnc-viewer

# Show current Tailscale connections
tailscale status

# Prompt for IP and port
read -rp "Enter IP: " ip
read -rp "Enter port: " port

# Open VNC viewer
vncviewer "$ip:$port"

# --- SSH Key Authentication Setup ---
# Generate an ed25519 key if not already present
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
fi

# Prompt for username and server
read -rp "Enter SSH username: " username
read -rp "Enter server IP or hostname: " server

# Copy SSH key to server
ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" "$username@$server"

# Open SSH session
ssh "$username@$server"


# 7. PDF
sudo apt install qpdf -y