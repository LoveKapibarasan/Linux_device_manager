

sudo mv client.conf /etc/wireguard/wg0.conf

# Enable and start the service
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Check status
sudo wg show

# Check GlobalIP
curl ifconfig.me
# [Peer]
# Change IP in server.conf if IP is changed
# Endpoint = IP:Port



# Interface List
ip a
# IP Routes
sudo ip route show