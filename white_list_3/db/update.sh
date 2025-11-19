#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# https://docs.pi-hole.net/database/domain-database/#domain-tables-domainlist
# Import functions
source "${SCRIPT_DIR}/../../util.sh"
source "${SCRIPT_DIR}/add_domain.sh"

root_check

## get lists
filter_hash  "${SCRIPT_DIR}/../../black_list/_black-list.csv"  "${SCRIPT_DIR}/../../black_list/black-list.csv" 
filter_hash  "${SCRIPT_DIR}/../../white_list/_white-list.csv"   "${SCRIPT_DIR}/../../white_list/white-list.csv"  

if [ ! -f "${SCRIPT_DIR}/gravity_template.db" ]; then
    cp /etc/pihole/gravity.db "${SCRIPT_DIR}/gravity_template.db"
fi

# === 1 ===
# regex blacklist: type=3
cp "${SCRIPT_DIR}/gravity_template.db"  "${SCRIPT_DIR}/gravity.db"
while IFS= read -r line; do
    [ -n "$line" ] && add_domain 3 "$line"  "${SCRIPT_DIR}/gravity.db"
done <  "${SCRIPT_DIR}/../../black_list/black-list.csv"
mv -f "${SCRIPT_DIR}/gravity.db" "${SCRIPT_DIR}/gravity_black.db"
chmod 700 "${SCRIPT_DIR}/gravity_black.db"

# === 2 ===
cp "${SCRIPT_DIR}/gravity_template.db"  "${SCRIPT_DIR}/gravity.db"
# regex whitelist: type=2
while IFS= read -r line; do
    [ -n "$line" ] && add_domain 2 "$line"  "${SCRIPT_DIR}/gravity.db"
done <  "${SCRIPT_DIR}/../../white_list/white-list.csv"

# regex blacklist: type=3
while IFS= read -r line || [ -n "$line" ]; do
    clean_line=$(echo "$line" | xargs)
    [ -n "$clean_line" ] && add_domain 3 "$clean_line" "${SCRIPT_DIR}/gravity.db"
done <  "${SCRIPT_DIR}/../../white_list/_block-list.csv"
mv -f "${SCRIPT_DIR}/gravity.db" "${SCRIPT_DIR}/gravity_current.db"
chmod 700 "${SCRIPT_DIR}/gravity_current.db"

