#!/bin/bash
# 引数: サービス名, 実行するスクリプトのパス 
patrol_service() {
    local service="$1"
    local path="$2"


    if ! systemctl is-active --quiet "$service"; then
        echo "[$service] is not active. Running $path in $dir ..."
        (
            cd "$dir" || exit 1
            sudo bash "$path"
        )
    else
        echo "[$service] is active. Nothing to do."
    fi
}
