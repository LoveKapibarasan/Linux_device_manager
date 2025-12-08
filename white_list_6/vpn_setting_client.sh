
interface_name='wg0'

sudo mv client.conf /etc/wireguard/${interface_name}.conf

# Enable and start the service
sudo systemctl enable wg-quick@${interface_name}
sudo systemctl start wg-quick@${interface_name}
sudo wg-quick up "${interface_name}"
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

# Change DNS
resolvectl dns wg0 8.8.8.8 1.1.1.1