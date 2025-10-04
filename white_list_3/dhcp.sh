#!/bin/bash

sudo apt install bridge-utils dnsmasq -y


interface eth0
static ip_address=192.168.42.1/24
nohook wpa_supplicant

cat <<EOF | sudo tee -a /etc/dnsmasq.conf 
interface=eth0
dhcp-range=192.168.42.10,192.168.42.100,255.255.255.0,24h
dhcp-option=6,8.8.8.8,1.1.1.1
EOF


cat <<EOF | sudo tee -a /etc/dhcpcd.conf

interface eth0
static ip_address=192.168.42.1/24
nohook wpa_supplicant
EOF

# Enable packet forwarding
sudo sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
# NAT
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# restore booting
iptables-restore < /etc/iptables.ipv4.nat
