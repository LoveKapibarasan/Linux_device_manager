
# remove empty and comment line
grep -vE '^\s*#|^\s*$' _white-list.csv > white-list.csv        