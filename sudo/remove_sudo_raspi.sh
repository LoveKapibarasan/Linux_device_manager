#!/usr/bin/env bash
set -e
sudo deluser username sudo
sudo rm /etc/sudoers.d/010_pi_passwd
sudo lsudo
sudo rm /etc/sudoers.d/010_pi_passwd
sudo ls
sudo rm .env
