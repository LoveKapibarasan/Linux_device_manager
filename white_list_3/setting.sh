#!/bin/bash
# su -c ./script.sh

# Import functions
. ../util.sh

root_check

sudo ./generate_pass.sh

sudo ./pihole_protect.sh