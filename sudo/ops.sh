#!/bin/bash

# Safer: sudo visudo -f /etc/sudoers.d/ops

sudo tee /etc/sudoers.d/ops > /dev/null <<'EOF'
# ログ閲覧/サービス操作
Cmnd_Alias SERVICE_OPS = /usr/bin/systemctl start *, /usr/bin/systemctl restart *

# パッケージ管理 (Arch + Debian/Ubuntu)
Cmnd_Alias PACKAGE_MGR = /usr/bin/pacman, /usr/bin/yay, /usr/bin/apt, /usr/bin/apt-get

# その他
Cmnd_Alias OTHERS = /bin/rm /root/shutdown_cui/usage_file.json, /usr/bin/bpftrace, /usr/bin/tee

# ops グループに適用
%ops ALL=(ALL:ALL) NOPASSWD: SERVICE_OPS, PACKAGE_MGR, OTHERS
EOF
# permission should be 440
sudo chmod 0440 /etc/sudoers.d/ops
sudo groupadd ops
