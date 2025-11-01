#!/bin/bash

sudo snap install dbeaver-ce postgresql rabbitmq-server -y
sudo systemctl enable postgresql --now
sudo systemctl enable rabbitmq-server --now

# server
sudo apt install remmina remmina-plugin-rdp -y
