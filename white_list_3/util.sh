
# remove empty and comment lines
grep -vE '^\s*#|^\s*$' file.sh > tmp.txt