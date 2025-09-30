#!/bin/bash

# Import functions
source ../util.sh
root_check



./add_zsh_d.sh
./add_aliase.sh
./add_wrapper.sh
./add_functions.sh
./add_sudo_wrapper.sh
./create_venv.sh
