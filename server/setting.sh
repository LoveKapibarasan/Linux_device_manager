#!/bin/bash

mkdir -p ~/.config/systemd/user
cp wayvnc.service ~/.config/systemd/user/wayvnc.service

systemctl --user daemon-reload
systemctl --user enable --now wayvnc.service

systemctl --user status wayvnc.service

tailscale ip -4 # IP
tailscale status # Magic Name

