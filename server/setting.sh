#!/usr/bin/env bash

sudo apt install docker-compose docker.io -y
sudo usermod -aG docker $USER
newgrp docker



sudo sysctl -w net.ipv4.conf.all.src_valid_mark=1
docker compose up wireguard -d