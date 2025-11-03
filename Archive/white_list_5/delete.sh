#!/bin/bash
sudo rm -f /usr/lib/libnss_regex.so.2
sudo rm -f /etc/regexhosts

BEFORE="^hosts:"
AFTER="hosts: files dns mymachines resolve [!UNAVAIL=return] myhostname"

sudo sed -i "/$BEFORE/c\\$AFTER" /etc/nsswitch.conf