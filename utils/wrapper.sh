#!/bin/bash
./add_zsh_d.sh
./add_aliase.sh
./add_wrapper_scripts.sh
./add_functions.sh
./add_sudo_wrapper.sh

# Get the home directory of the user who invoked sudo
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi

echo "Using home directory: $USER_HOME"

cd $USER_HOME/enc-private/enc-private/config

HOME="$USER_HOME" ./config_bak.sh
