#!/bin/bash
sudo rm -f /usr/lib/libnss_regex.so.2
sudo rm -f /etc/regexhosts
sudo sed -i '/^hosts:/c\hosts: files dns mymachines resolve [!UNAVAIL=return] myhostname' /etc/nsswitch.conf