# .env
set -a
source .env
set +a

sudo apt update -y
sudo apt install wireguard -y

wg genkey | tee server_private.key | wg pubkey > server_public.key

wg genkey | tee client_private.key | wg pubkey > client_public.key
wg genkey | tee client_private_win.key | wg pubkey > client_public_win.key

# ip link add dev server type wireguard
# ip link set up dev server

# Use 10.10 to avoid conflict
echo "Down server before editing this file."
sudo tee /etc/wireguard/server.conf <<EOF
[Interface]
# server virtual interface address
Address = 10.10.0.1/24
ListenPort = 51820
SaveConfig = true
PrivateKey = $(cat server_private.key)
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens5 -j MASQUERADE
[Peer]
PublicKey = $(cat client_public.key)
AllowedIPs = 10.10.0.2/32 # Client Virtual IP address
[Peer]
PublicKey = $(cat client_public_win.key)
AllowedIPs = 10.10.0.3/32
EOF

# %i: like eth0 check with `sudo wg`
# server is interface name
sudo systemctl enable wg-quick@server
sudo systemctl start wg-quick@server

# Port UDP 51820

sudo tee /etc/wireguard/client.conf <<EOF
[Interface]
PrivateKey = $(cat client_private.key)
# Server 10.10.0.1/24 → Client 10.0.0.2/24, 10.0.0.3/24...
Address = 10.10.0.2/24
DNS=${DNS_IP}
[Peer]
PublicKey = $(cat server_public.key)
# IP route that should pass into VPN
AllowedIPs = 10.10.0.1/32 # All Traffic via Tunnel 0.0.0.0/0
Endpoint = ${DNS_IP}:51820
PersistentKeepalive = 25
EOF
sudo chmod 600 /etc/wireguard/server.conf
sudo chmod 600 /etc/wireguard/client.conf

echo "Use this."
sudo cat /etc/wireguard/client.conf

# Packet Forwarding
## Temporal
sudo sysctl -w net.ipv4.ip_forward=1

sudo tee /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 1
EOF
sudo sysctl -p
# EC2 -> Out
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
