#!/bin/bash

# Import functions
. ../util.sh
root_check

USER_HOME=$(get_user_home)
echo "Using home directory: $USER_HOME"


./add_zsh_d.sh
./add_aliase.sh
./add_wrapper.sh
./add_functions.sh
./add_sudo_wrapper.sh
./create_venv.sh
