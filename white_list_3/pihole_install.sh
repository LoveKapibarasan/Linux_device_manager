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



# Pi-hole 以外のDNS通信を全ブロック
sudo iptables -A OUTPUT ! -d 10.0.0.2 -p udp --dport 53 -j REJECT
sudo iptables -A OUTPUT ! -d 10.0.0.2 -p tcp --dport 53 -j REJECT

# Cloudflare/GoogleへのDoHアクセスも潰す（HTTPS 443宛 DNS）
sudo iptables -A OUTPUT -p tcp --dport 443 -d 1.1.1.1 -j REJECT
sudo iptables -A OUTPUT -p tcp --dport 443 -d 8.8.8.8 -j REJECT
sudo iptables -A OUTPUT -p tcp --dport 443 -d 8.8.4.4 -j REJECT

sudo vim /etc/systemd/resolved.conf
# and add
#DNS=10.0.0.2
#FallbackDNS=

# Disable Apache → Pi-hole 標準lighttpdが使えるように
sudo systemctl stop apache2
sudo systemctl disable apache2

# delete lightpd
sudo systemctl stop lighttpd.service
sudo systemctl disable lighttpd.service
sudo systemctl restart pihole-FTL.service



