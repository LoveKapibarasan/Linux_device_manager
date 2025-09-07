#!/bin/bash
# https://sourceware.org/git/?p=glibc.git;a=blob_plain;f=nss/nss_files/files-hosts.c;hb=HEAD

# Import functions
. ../util.sh

gcc -fPIC -shared -o libnss_regex.so.2 nss_regex.c -ldl -Wall
sudo cp libnss_regex.so.2 /usr/lib/   # or /lib/x86_64-linux-gnu/


filter_hash _white-list.csv  white-list.csv        
sudo cp white-list.csv /etc/regexhosts
cat /etc/regexhosts

BEFORE="^hosts:"
AFTER="hosts: files regex dns mymachines resolve [!UNAVAIL=return] myhostname"
sudo sed -i "s|$BEFORE.*|$AFTER|" /etc/nsswitch.conf

cat /etc/nsswitch.conf
journalctl -t regexhosts -f

