#!/usr/bin/env bash

sudo cp pihole.service /etc/systemd/system/

# === Protect pihole ===
sudo mkdir -p /opt/pihole
sudo chown root:root /opt/pihole
sudo chmod 700 /opt/pihole

sudo cp docker-compose.yml /opt/pihole/
sudo cp .env /opt/pihole
sudo systemctl daemon-reload
sudo systemctl enable --now pihole.service

systemctl status pihole.service

890a
sudo vim /etc/resolv.conf
# and only nameserver 127.0.0.1


# 2-1-1.
sudo vim /etc/NetworkManager/NetworkManager.conf
# If NetworkManager edit this,
# [main]
# dns=none
# 2-1-2.
sudo vim /etc/NetworkManager/conf.d/dns-reject.conf
# [main]
# dns=default
 
# [ipv4]
# ignore-auto-dns=true
# dns=127.0.0.1;

# [ipv6]
# ignore-auto-dns=true
# dns=::1;

# 2-1-2.
sudo vim /etc/systemd/resolved.conf
# [Resolve]
# DNS=127.0.0.1
# Domains=~.
# DNSStubListener=no

sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved

cat /etc/resolv.conf
cat /etc/systemd/resolved.conf
cat /run/systemd/resolve/resolv.conf
cat /etc/systemd/resolved.conf.d/dns.conf

# 2-2-2.
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved




# set password
sudo -s
cd /opt/pihole
echo "ADMIN_PASSWORD=$(openssl rand -base64 20)" | sudo tee .env
docker exec -it pihole pihole setpassword "$(grep ADMIN_PASSWORD .env | cut -d'=' -f2)"



##############################################
# Nites
# 1. Rate limit
#      FTLCONF_dns_rateLimit_count: 0
#      FTLCONF_dns_rateLimit_interval: 0
# in env

# 2. gravity.db is setting file for domains
# 3. ArchLinux <= NetworkManager, systemd-resolved
#    Raspi Lite <= NetworkManager