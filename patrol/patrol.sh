#!/bin/bash

# 1. patrol.sh 実行
cd "/home/${USER}/Linux_device_manager" || exit 1
./patrol.sh

# 2. rm_sudo.sh 実行
cd "/home/${USER}/Linux_device_manager/patrol" || exit 1
./rm_sudo.sh

# 3. run gp
cd "/home/${USER}/Linux_device_manager/git/gp.sh" || exit 1
./gp.sh