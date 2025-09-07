
# remove empty and comment line
grep -vE '^\s*#|^\s*$' _black-list.csv > black-list.csv  
grep -vE '^\s*#|^\s*$' _white-list.csv > white-list.csv        