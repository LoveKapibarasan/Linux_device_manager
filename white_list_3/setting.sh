#!/bin/bash
# su -c ./script.sh

# Import functions
. ../util.sh

root_check

curl -sSL https://install.pi-hole.net | bash
# choose wlp3s0 interface
# choose cloudflare or google
# show everything for ETL
# sudo setpassword

chmod +x generate_pass.sh
sudo ./generate_pass.sh

sudo ./pihole_protect.sh