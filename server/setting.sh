#!/usr/bin/env bash

## On-Premises = 「敷地内に」 Server
### (Premise= 前提、仮定)

sudo apt install docker-compose docker.io -y
sudo usermod -aG docker $USER
newgrp docker



sudo sysctl -w net.ipv4.conf.all.src_valid_mark=1
docker compose up wireguard -d

# Default Gateway Setting to reset
sudo ip route add default via 10.0.0.1

sudo mkdir -p /etc/systemd/system/ssh.socket.d
sudo bash -c 'cat > /etc/systemd/system/ssh.socket.d/listen.conf <<EOF
[Socket]
ListenStream=
ListenStream=0.0.0.0:22
ListenStream=[::]:22
ListenStream=0.0.0.0:2222
ListenStream=[::]:2222
EOF'
sudo systemctl daemon-reload
sudo systemctl restart ssh.socket
sudo ss -tlnp | grep -E ':(22|2222)'

ssh-keygen -t ed25519 -C "xxx@yyy"
ssh-copy-id -p 2222 -i ~/.ssh/server.pub user@$server_ip
sudo vim /etc/ssh/sshd_config
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
# Port 22
# Port 2222
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config.d/50-cloud-init.conf
# Check
sudo sshd -T | grep pubkeyauth
sudo sshd -T | grep passwordauthentication

# Shogihome
git clone -o upstream git@github.com:sunfish-shogi/shogihome.git

# Pihole
mkdir -p "$HOME/Linux_device_manager/server/etc-pihole"
sudo mv "$HOME/Linux_device_manager/white_list_3/db/gravity_current.db" "$HOME/Linux_device_manager/server/etc-pihole/gravity.db"
### Stop systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl mask systemd-resolved
sudo vim /etc/resolv.conf # 1.1.1.1
### Normal
### sshd checks port → connect

### Socket Activation：
### systemd checks port → Run sshd
# sudo systemctl mask ssh.socket
sudo systemctl cat ssh.socket
sudo vim /lib/systemd/system/ssh.socket
sudo vim /etc/systemd/system/ssh.socket.d/listen.conf

# Vaultwarden
## account -> security -> 2FA

# Searxng
### Permission Error
sudo chown -R $USER:$USER searxng/
docker compose logs searxng | grep "Listening"
### secret_key: "$(openssl rand -hex 32)"  # change this!!!

# 1. Firefox:
## https://search.lovekapibarasan.org/search?q=%s
## https://search.lovekapibarasan.org/autocomplete?q=%s
# 2. Edge
## edge://settings/searchEngines -> Make as default

# DB
chmod +x init-db.sh

# Mail Server
## tmp, domain
## !! in 2 minutes !!
docker exec -it mailserver setup email add user@example.com
## postmaster(mail admin, receives spam mail info) --> user@example.com
docker exec -it mailserver setup alias add postmaster@example.com user@example.com
## DKIM
docker exec -it mailserver setup config dkim
cat ./docker-data/dms/config/opendkim/keys/example.com/mail.txt
## Add TXT record
### TXT mail._domainkey.example.com v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBg...(selector 'mail' is free to choose)
## SPF (Sender Policy Framework)
### example.com. IN TXT "v=spf1 ip4:192.0.2.10 ip4:192.0.2.20 -all"
docker exec mailserver setup email list
## DMARC (Domain-based Message Authentication, Reporting and Conformance)
### _dmarc.example.com. IN TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"
## DEBUG
openssl s_client -connect ${DOMAIN_OR_IP}:993
# Port25: https://console.aws.amazon.com/support/contacts?#/rdns-limits

# Open WebUI
## General -> Connectors
### OpenAI: https://api.openai.com/v1
### Anthropic: Register pipeline Functions(https://github.com/jeremysears/anthropic-manifold-pipeline/blob/main/anthropic_manifold_pipeline.py)


# TTS
git clone -o upstream git@github.com:Femoon/tts-azure-web.git
## .env.local
## "dev": "next dev -p 3003"
## westeurope


# GitLab
## Gitlab: Settings → Repository → Mirroring repositories
## Github: Setting -> Deploy keys
### Add ssh:// and enter private key
### Permission Error:
docker exec -it gitlab-server bash
chmod 600 /etc/gitlab/ssh_host_*
chmod 700 /etc/gitlab
exit
#### Regenerate GitLab keys
docker exec -it gitlab-server gitlab-ctl reconfigure
docker exec -it gitlab-server gitlab-ctl restart sshd

# Nextcloud
docker exec -it nextcloud bash
vi /var/www/html/config/config.php
# trusted_domains' => 
# array (
#  0 => 'localhost',
#  1 => '127.0.0.1',
# or
docker exec -u www-data nextcloud php occ config:system:set trusted_domains 0 --value=localhost
docker exec -u www-data nextcloud php occ config:system:set trusted_domains 1 --value=127.0.0.1

docker exec -u www-data nextcloud php occ app:install tasks
docker exec -u www-data nextcloud php occ app:install calendar

# DEBUG
sudo apt install traceroute
## Use outer DNS server
sudo vim /etc/resolv.conf

# Samba
## Windows
### Map Network Drive
### Drive Letter: Z
### Folder :\\SAMBA_server_IP\Data
### cmd /c cmdkey /add:10.10.0.1 /user:samba /pass:password
### cmdkey /list
## Ubuntu(Natrius)
### Ctrl + L -> smb://SAMBA_server_IP/Data
### Right Click -> Add to bookmarks


# Jellyfin
## Permission Error
chmod -R 777 ./config ./cache
## Dashboard -> Scan All Libraries

# Roundcube
docker exec -it roundcube sed -i "s|^\$config\['default_host'\].*|\$config['default_host'] = 'ssl://imap.%s';|" /var/www/html/config/config.docker.inc.php
#  echo "\$config['default_host'] = 'ssl://imap.%s';" >>  /var/www/html/config/config.inc.php
docker restart roundcube
### Note: Some region does not have mail server
### nc -vz imap.mail.us-east-1.awsapps.com 993
### Access control rules -> Use these protocols -> IMAP

# MKDocs
# 0 */2 * * * /usr/bin/docker restart mkdocs

# Portainer.io
## Environments -> Add environment -> Docker Standalone -> Agent

# Unbound
### In AWS 
### DNAT
sudo iptables -t nat -A PREROUTING -p tcp --dport 853 -j DNAT --to-destination 10.10.0.2:853
sudo iptables -A FORWARD -p tcp -d 10.10.0.2 --dport 853 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Anki
# https://docs.ankiweb.net/sync-server.html
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
sudo apt install -y protobuf-compiler
rustup install 1.82.0
rustup override set 1.82.0
cargo install --locked \
  --git https://github.com/ankitects/anki.git \
  --tag 25.02.5 \
SYNC_USER1=user:pass SYNC_PORT=9003 anki-sync-server
which anki-sync-server
# Default Path
ls -a ~/.syncserver/user/

sudo systemctl daemon-reload
sudo systemctl enable --now anki-sync-server
# Tools -> Preferences -> Sync
# Do not forget tail /
