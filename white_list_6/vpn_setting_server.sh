# .env
set -a
source .env
set +a

sudo apt update -y
sudo apt install wireguard -y

# Define OS list
OS_LIST="ubuntu fedora win"


wg genkey | tee server_private.key | wg pubkey > server_public.key

# Generate client keys for each OS
for os in $OS_LIST; do
    os_lower=$(echo "$os" | tr '[:upper:]' '[:lower:]')
    wg genkey | tee "client_private_${os_lower}.key" | wg pubkey > "client_public_${os_lower}.key"
done


ip link add dev server type wireguard
ip link set up dev server

sudo iptables -I FORWARD -i server -j ACCEPT
sudo iptables -I FORWARD -o server -j ACCEPT

# Build peer configurations dynamically
PEER_CONFIG=""
IP_COUNTER=2
for os in $OS_LIST; do
    os_lower=$(echo "$os" | tr '[:upper:]' '[:lower:]')
    PEER_CONFIG+="[Peer]
PublicKey = $(cat "client_public_${os_lower}.key")
AllowedIPs = 10.10.0.${IP_COUNTER}/32

"
    IP_COUNTER=$((IP_COUNTER + 1))
done


# %i: like eth0 or ens5 check with `sudo wg`

echo "Down server before editing this file."
# Create server configuration
sudo tee /etc/wireguard/server.conf <<EOF
[Interface]
# server virtual interface address
Address = 10.10.0.1/24
ListenPort = 51820
SaveConfig = true
PrivateKey = $(cat server_private.key)
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens5 -j MASQUERADE

${PEER_CONFIG}
EOF

# server is interface name
sudo systemctl enable wg-quick@server
sudo systemctl start wg-quick@server

# Port UDP 51820
# 10.0.0.x is problematic for AWS.

# Generate client configurations for each OS
IP_COUNTER=2
for os in $OS_LIST; do
    os_lower=$(echo "$os" | tr '[:upper:]' '[:lower:]')
    
    sudo tee "/etc/wireguard/client_${os_lower}.conf" <<EOF
[Interface]
PrivateKey = $(cat "client_private_${os_lower}.key")
# Server 10.10.0.1/24 → Client 10.10.0.2/24, 10.10.0.3/24...
Address = 10.10.0.${IP_COUNTER}/24
DNS=${DNS_IP}

[Peer]
PublicKey = $(cat server_public.key)
# IP route that should pass into VPN
AllowedIPs = 10.10.0.1/32 # All Traffic via Tunnel 0.0.0.0/0
Endpoint = ${DNS_IP}:51820
PersistentKeepalive = 25
EOF

    sudo chmod 600 "/etc/wireguard/client_${os_lower}.conf"
    echo "=== Client config for ${os} ==="
    sudo cat "/etc/wireguard/client_${os_lower}.conf"
    echo ""
    
    IP_COUNTER=$((IP_COUNTER + 1))
done

sudo chmod 600 /etc/wireguard/server.conf

# !! Make sure the correct public-private key pairs !!


# Packet Forwarding
## Temporal
sudo sysctl -w net.ipv4.ip_forward=1

sudo tee /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 1
EOF
sudo sysctl -p


sudo wg show all