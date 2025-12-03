#!/usr/bin/env bash

sudo apt install docker-compose docker.io -y
sudo usermod -aG docker $USER
newgrp docker



sudo sysctl -w net.ipv4.conf.all.src_valid_mark=1
docker compose up wireguard -d

# Default Gateway Setting to reset
sudo ip route add default via 10.0.0.1

# Open Port 2222
### sudo vim /etc/ssh/sshd_config

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


git clone -o upstream git@github.com:sunfish-shogi/shogihome.git


mkdir -p "$HOME/Linux_device_manager/server/etc-pihole"
sudo mv "$HOME/Linux_device_manager/white_list_3/db/gravity_current.db" "$HOME/Linux_device_manager/server/etc-pihole/gravity.db"