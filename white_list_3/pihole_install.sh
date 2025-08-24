#!/usr/bin/env bash
sudo apt purge pihole-meta -y
sudo rm -rf /etc/.pihole /etc/pihole

sudo su -
curl -sSL https://install.pi-hole.net | bash
# choose wlp3s0 interface
# choose cloudflare or google
# show everything for ETL
# sudo setpassword
# http://<ip_address>/admin/login
