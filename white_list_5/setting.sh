#!/bin/bash
# https://sourceware.org/git/?p=glibc.git;a=blob_plain;f=nss/nss_files/files-hosts.c;hb=HEAD

gcc -fPIC -shared -o libnss_regex.so.2 nss_regex.c -ldl -Wall
sudo cp libnss_regex.so.2 /usr/lib/   # or /lib/x86_64-linux-gnu/


sudo cp ../white_list_3/white-list.csv /etc/regexhosts
cat /etc/regexhosts


