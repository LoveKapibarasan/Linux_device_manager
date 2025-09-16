#!/bin/bash

# Import functions
. ../util.sh

root_check

# Safer: sudo visudo -f /etc/sudoers.d/ops
which nordvpn
which openfortivpn


sudo tee /etc/sudoers.d/ops > /dev/null <<'EOF'
# ログ閲覧/サービス操作
Cmnd_Alias SERVICE_OPS = /usr/bin/systemctl start *, /usr/bin/systemctl restart *

# パッケージ管理 (Arch + Debian/Ubuntu)
Cmnd_Alias PACKAGE_MGR = /usr/bin/pacman, /usr/bin/yay, /usr/bin/apt, /usr/bin/apt-get

# VPN 接続/切断
Cmnd_Alias VPN_OPS = /usr/bin/nordvpn connect jp, \
                         /usr/bin/nordvpn connect de, \
                         /usr/bin/nordvpn disconnect, \
                         /usr/bin/openfortivpn

# ops グループに適用
%ops ALL=(ALL:ALL) NOPASSWD: SERVICE_OPS, PACKAGE_MGR, VPN_OPS
EOF

# permission should be 440
sudo chmod 0440 /etc/sudoers.d/ops
sudo groupadd ops
