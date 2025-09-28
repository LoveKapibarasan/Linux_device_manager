#!/bin/bash

# import
source ./util.sh

# Check root
root_check

enable_resolved

cd "${USER_HOME}/Linux_device_manager/utils/sudo_python_scripts/captive_portal"

./venv/bin/python captive_portal.py 

disable_resolved
