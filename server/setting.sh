#!/usr/bin/env bash

sudo apt install docker-compose docker.io -y
sudo usermod -aG docker $USER
newgrp docker