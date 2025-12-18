#!/bin/bash

# Loki
sudo iptables -t nat -A PREROUTING -p tcp --dport 3100  -j DNAT --to-destination 10.10.0.2:3100
sudo iptables -A FORWARD -p tcp -d 10.10.0.2 --dport 3100 -j ACCEPT

# Portainer.io
sudo iptables -t nat -A PREROUTING -p tcp --dport 9001 -j DNAT --to-destination 10.10.0.4:9001
sudo iptables -A FORWARD -p tcp -d 10.10.0.4 --dport 9001 -j ACCEPT

# Prometheus
sudo iptables -t nat -A PREROUTING -p tcp --dport 9090  -j DNAT --to-destination 10.10.0.2:9090
sudo iptables -A FORWARD -p tcp -d 10.10.0.2 --dport 9090 -j ACCEPT