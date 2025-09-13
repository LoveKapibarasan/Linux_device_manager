#!/bin/bash
# Get the home directory of the user who invoked sudo
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi
echo "Using home directory: $USER_HOME"


HOME="$USER_HOME" ./add_zsh_d.sh
HOME="$USER_HOME" ./add_aliase.sh
HOME="$USER_HOME" ./add_wrapper_scripts.sh
HOME="$USER_HOME" ./add_functions.sh
HOME="$USER_HOME" ./add_sudo_wrapper.sh


cd $USER_HOME/enc-private/enc-private/config

HOME="$USER_HOME" ./config_bak.sh
