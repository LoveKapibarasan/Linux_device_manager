#!/bin/bash

# Tailscale Wayvnc openssh
sudo pacman -S wayvnc
vncpasswd ~/.vncpasswd
chmod 600 ~/.vncpasswd
wayvnc 0.0.0.0 5900 -p ~/.vncpasswd
ss -tlnp | grep 5900 # This should not be 127.0.0.1

sudo pacman -S openssh
sudo systemctl enable --now sshd
systemctl status sshd
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT


sudo pacman -S tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
tailscale ip -4
sudo systemctl enable --now sshd
sudo tailscale up --accept-dns=false