#!/bin/bash
# https://sourceware.org/git/?p=glibc.git;a=blob_plain;f=nss/nss_files/files-hosts.c;hb=HEAD

# .so = .dll

gcc -fPIC -shared -o libnss_regex.so.2 nss_regex.c -ldl -Wall
sudo cp libnss_regex.so.2 /usr/lib/   # or /lib/x86_64-linux-gnu/


grep -vE '^\s*#|^\s*$' ../white_list_3/_white-list.csv > ../white_list_3/white-list.csv        
sudo cp ../white_list_3/white-list.csv /etc/regexhosts
cat /etc/regexhosts

# xxx <-> libness_xxx.so.2

sudo sed -i '/^hosts:/c\hosts: files regex dns mymachines resolve [!UNAVAIL=return] myhostname' /etc/nsswitch.conf
cat /etc/nsswitch.conf

