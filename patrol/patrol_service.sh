#!/bin/bash

# サービス → {ディレクトリ, 実行スクリプト} の対応表
declare -A DIRS
declare -A SCRIPTS

DIRS["shutdown-cui"]="/home/${USER}/Linux_device_manager/blocker_2"
SCRIPTS["shutdown-cui"]="setting.sh"

DIRS["pihole"]="/home/${USER}/Linux_device_manager/white_list_3"
SCRIPTS["pihole"]="setting_docker.sh"


LOGFILE="/var/log/patrol.log"

for SERVICE in "${!SCRIPTS[@]}"; do
  if ! systemctl is-active --quiet "$SERVICE"; then
    echo "$(date): $SERVICE is not active, running ${SCRIPTS[$SERVICE]}" >> "$LOGFILE"
    (
      cd "${DIRS[$SERVICE]}" || exit
      bash "${SCRIPTS[$SERVICE]}"
    )
  fi
done
