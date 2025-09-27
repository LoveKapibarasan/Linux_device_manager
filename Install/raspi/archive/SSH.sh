#!/bin/bash

# Tailscale SSH
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable tailscaled
sudo systemctl start tailscaled
sudo tailscale up
sudo tailscale up --accept-dns=false

# Show current Tailscale connections
tailscale status

# Prompt for IP and port
read -rp "Enter IP: " ip
read -rp "Enter port: " port


# --- SSH Key Authentication Setup ---
# Generate an ed25519 key if not already present
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
fi

# Prompt for username and server
read -rp "Enter SSH username: " username
read -rp "Enter server IP or hostname: " server

# Copy SSH key to server
ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" "$username@$server"

# Open SSH session
ssh "$username@$server"

# PubkeyAuthentication を有効化
sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# PasswordAuthentication を無効化
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
