#!/bin/bash

# このスクリプトがあるディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# import
chmod +x "$SCRIPT_DIR/patrol_service.sh"
source "$SCRIPT_DIR/patrol_service.sh"

patrol_service "pihole" "$SCRIPT_DIR/../white_list_3/setting_docker.sh"
patrol_service "shutdown-cui" "$SCRIPT_DIR/../blocker_2/setting.sh"

chmod +x "$SCRIPT_DIR/rm_sudo.sh"
"$SCRIPT_DIR/rm_sudo.sh"

cd "$SCRIPT_DIR/git" || exit 1
chmod +x gp.sh
./gp.sh