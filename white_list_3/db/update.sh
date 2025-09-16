#!/bin/bash


# https://docs.pi-hole.net/database/domain-database/#domain-tables-domainlist
# Import functions
. ../../util.sh
. ./add_domain.sh

root_check

## get lists
filter_hash ../../black_list/_black-list.csv  ../../black_list/black-list.csv  
filter_hash ../../white_list/_white-list.csv  ../../white_list/white-list.csv  

# ブラックリスト投入 (regex blacklist: type=3)
while IFS= read -r line; do
    [ -n "$line" ] && add_domain 3 "$line" ./gravity_black.db
done < ../../black_list/black-list.csv

# ホワイトリスト投入 (regex whitelist: type=2)
while IFS= read -r line; do
    [ -n "$line" ] && add_domain 2 "$line" ./gravity_current.db
done < ../../white_list/white-list.csv

# ブロックリスト (regex blacklist: type=3)
while IFS= read -r line || [ -n "$line" ]; do
    clean_line=$(echo "$line" | xargs)
    [ -n "$clean_line" ] && add_domain 3 "$clean_line" ./gravity_current.db
done < ../../white_list/_block-list.csv


