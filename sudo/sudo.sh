#!/bin/bash



# 1. Add sudo
su -

usermod -aG sudo <username>
usermod -aG wheel <username>
usermod -aG docker <username>

# 2. remove from sudo
gpasswd -d <username> sudo
gpasswd -d <username> wheel
gpasswd -d <username> docker
