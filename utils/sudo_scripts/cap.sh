#!/bin/bash


if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi
echo "Using home directory: $USER_HOME"

# import
source ${USER_HOME}/Linux_device_manager/util.sh


# Check root
root_check

enable_resolved

cd "${USER_HOME}/Linux_device_manager/utils/sudo_python_scripts/captive_portal"

./venv/bin/python captive_portal.py 

disable_resolved
