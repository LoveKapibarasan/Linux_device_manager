#!/bin/bash

# このスクリプトがあるディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# import
chmod +x "$SCRIPT_DIR/patrol_service.sh"
source "$SCRIPT_DIR/patrol_service.sh"

# 1 service
patrol_service "shutdown-cui" "$SCRIPT_DIR/../blocker_2/setting.sh"
patrol_service "patrol" "$SCRIPT_DIR/setting.sh"

# 2 
cd "$SCRIPT_DIR" || exit 1
chmod +x rm_sudo.sh
sudo ./rm_sudo.sh
# 700
chmod +x 700.sh
sudo ./700.sh
# update
chmod +x update.sh
sudo ./update.sh

# 3 gp
cd "$SCRIPT_DIR/git" || exit 1
chmod +x gp.sh
./gp.sh

