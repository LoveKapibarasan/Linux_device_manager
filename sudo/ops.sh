#!/bin/bash

# Safer: sudo visudo -f /etc/sudoers.d/ops

sudo tee /etc/sudoers.d/ops > /dev/null <<'EOF'
# ログ閲覧/サービス操作
Cmnd_Alias SERVICE_OPS = /usr/bin/systemctl start *, /usr/bin/systemctl restart *

# パッケージ管理 (Arch + Debian/Ubuntu)
Cmnd_Alias PACKAGE_MGR = /usr/bin/pacman, /usr/bin/yay, /usr/bin/apt, /usr/bin/apt-get

# NordVPN 接続/切断
Cmnd_Alias NORDVPN_OPS = /usr/bin/nordvpn connect jp, \
                         /usr/bin/nordvpn connect de, \
                         /usr/bin/nordvpn disconnect

# ops グループに適用
%ops ALL=(ALL:ALL) NOPASSWD: SERVICE_OPS, PACKAGE_MGR, NORDVPN_OPS
EOF



# permission should be 440
sudo chmod 0440 /etc/sudoers.d/ops
sudo groupadd ops
