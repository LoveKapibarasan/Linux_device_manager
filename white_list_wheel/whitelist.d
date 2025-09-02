# visudo -f /etc/sudoers.d/ops

# ops グループのユーザに対して限定的な sudo 権限を付与

# ログ閲覧
Cmnd_Alias LOGS = /usr/bin/journalctl -xe, /usr/bin/less /var/log/*

# サービスの開始・再起動のみ許可 (停止・無効化は禁止)
Cmnd_Alias SERVICE_OPS = /usr/bin/systemctl start *, /usr/bin/systemctl restart *

# パッケージ管理 (Arch Linux)
Cmnd_Alias PACKAGE_MGR = /usr/bin/pacman, /usr/bin/yay

# ops グループに適用
%ops ALL=(ALL:ALL) NOPASSWD: LOGS, SERVICE_OPS, PACKAGE_MGR
