
# remove empty and comment lines
pc% grep -vE '^\s*#|^\s*$' white-list.csv > tmp.txt        