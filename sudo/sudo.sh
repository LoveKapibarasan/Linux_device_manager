#!/bin/bash

# 0. Basic Group
getent group

sudo visudo -f /etc/sudoers.d/ops # See ops
sudo groupadd ops

sudo usermod -aG systemd-journal ${USER}
sudo usermod -aG postgres ${USER}
sudo usermod -aG rabbitmq ${USER}
sudo usermod -aG ops ${USER}
sudo usermod -aG nordvpn ${USER}

# 1. Add sudo
su -

usermod -aG sudo <username>
usermod -aG wheel <username>
usermod -aG docker <username>

# 2. remove from sudo
gpasswd -d <username> sudo
gpasswd -d <username> wheel
gpasswd -d <username> docker

# 3 Check
groups <username>
id <username>
getent group wheel sudo
