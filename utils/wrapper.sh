#!/bin/bash

# Import functions
. ../util.sh
root_check

USER_HOME=$(get_user_home)
echo "Using home directory: $USER_HOME"


HOME="$USER_HOME" ./add_zsh_d.sh
HOME="$USER_HOME" ./add_aliase.sh
HOME="$USER_HOME" ./add_wrapper.sh
HOME="$USER_HOME" ./add_functions.sh
HOME="$USER_HOME" ./add_sudo_wrapper.sh