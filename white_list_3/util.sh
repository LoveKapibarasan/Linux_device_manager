
# remove empty and comment line
grep -vE '^\s*#|^\s*$' white-list.csv > tmp.txt        