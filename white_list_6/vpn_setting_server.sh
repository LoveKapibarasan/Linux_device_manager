# .env
source .env

sudo apt update -y
sudo apt install wireguard git -y

# Define OS list
OS_LIST="vm ubuntu ubuntu win android"


wg genkey | tee server_private.key | wg pubkey > server_public.key

# Generate client keys for each OS
for os in $OS_LIST; do
    os_lower=$(echo "$os" | tr '[:upper:]' '[:lower:]')
    wg genkey | tee "client_private_${os_lower}.key" | wg pubkey > "client_public_${os_lower}.key"
done


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

sudo tee /etc/wireguard/"$wg_server_interface".conf <<EOF
[Interface]
# server virtual interface address
Address = ${WG_Server}/24
ListenPort = 51820
SaveConfig = true
PrivateKey = $(cat server_private.key)

# Enable IP packet transfer
PostUp = sysctl -w net.ipv4.ip_forward=1

# DNS転送
PostUp = iptables -t nat -A PREROUTING -i ${wg_server_interface} -p udp --dport 53 -j DNAT --to-destination ${HOME_PC}:53
PostUp = iptables -t nat -A PREROUTING -i ${wg_server_interface} -p tcp --dport 53 -j DNAT --to-destination ${HOME_PC}:53
# Interface Automatically change
PostUp = iptables -t nat -A PREROUTING -i ${wg_server_interface} -p tcp --dport 3309 -j DNAT --to-destination ${WIN_IP}:3309
PostUp = iptables -t nat -A PREROUTING -d ${IP} -p tcp --dport 80 -j DNAT --to-destination ${HOME_PC}:80
PostUp = iptables -t nat -A PREROUTING -d ${IP} -p tcp --dport 8080 -j DNAT --to-destination ${HOME_PC}:8080
PostUp = iptables -t nat -A PREROUTING -d ${IP} -p tcp --dport 53 -j DNAT --to-destination ${HOME_PC}:53
PostUp = iptables -t nat -A PREROUTING -d ${IP} -p udp --dport 53 -j DNAT --to-destination ${HOME_PC}:53

# SNAT
PostUp = iptables -t nat -A POSTROUTING -d ${HOME_PC} -p udp --dport 53 -j MASQUERADE
PostUp = iptables -t nat -A POSTROUTING -d ${HOME_PC} -p tcp --dport 53 -j MASQUERADE
# 一般的なマスカレード
PostUp = iptables -t nat -A POSTROUTING -o ${interface_name} -j MASQUERADE

PostDown = sysctl -w net.ipv4.ip_forward=0

PostDown = iptables -t nat -D PREROUTING -i ${wg_server_interface} -p udp --dport 53 -j DNAT --to-destination ${HOME_PC}:53
PostDown = iptables -t nat -D PREROUTING -i ${wg_server_interface} -p tcp --dport 53 -j DNAT --to-destination ${HOME_PC}:53
PostDown = iptables -t nat -D PREROUTING -d ${IP} -p tcp --dport 80 -j DNAT --to-destination ${HOME_PC}:80
PostDown = iptables -t nat -D PREROUTING -d ${IP} -p tcp --dport 8080 -j DNAT --to-destination ${HOME_PC}:8080
PostDown = iptables -t nat -D PREROUTING -d ${IP} -p tcp --dport 53 -j DNAT --to-destination ${HOME_PC}:53
PostDown = iptables -t nat -D PREROUTING -d ${IP} -p udp --dport 53 -j DNAT --to-destination ${HOME_PC}:53

PostDown = iptables -t nat -D POSTROUTING -d ${HOME_PC} -p udp --dport 53 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -d ${HOME_PC} -p tcp --dport 53 -j MASQUERADE

PostDown = iptables -t nat -D PREROUTING -i ${wg_server_interface} -p tcp --dport 3309 -j DNAT --to-destination ${WIN_IP}:3309
PostDown = iptables -t nat -D POSTROUTING -o ${interface_name} -j MASQUERADE

${PEER_CONFIG}
EOF

# 1. Receive at ens5, eth0 ← PREROUTING (DNAT)
# 2. Check Routing Table
# 3. FORWARD chain ← wg0
# 4. send via wg0


sudo chmod 600 "/etc/wireguard/${wg_server_interface}.conf"
sudo systemctl "enable wg-quick@${wg_server_interface}"
sudo systemctl "start wg-quick@${wg_server_interface}"
sudo wg-quick up "${wg_server_interface}"

# Port UDP 51820
# 10.0.0.x is problematic for AWS.

# Generate client configurations for each OS
IP_COUNTER=2
for os in $OS_LIST; do
    os_lower=$(echo "$os" | tr '[:upper:]' '[:lower:]')
    
    sudo tee "/etc/wireguard/client_${os_lower}.conf" <<EOF
[Interface]
PrivateKey = $(cat "client_private_${os_lower}.key")
# Server ${WG_Server}/24 → Client 10.10.0.2/24, 10.10.0.3/24...
Address = 10.10.0.${IP_COUNTER}/24

[Peer]
PublicKey = $(cat server_public.key)
# IP route that should pass into VPN
AllowedIPs = ${WG_Server}/32 # All Traffic via Tunnel 0.0.0.0/0
Endpoint = ${IP}:51820
PersistentKeepalive = 25
EOF

    sudo chmod 600 "/etc/wireguard/client_${os_lower}.conf"
    echo "=== Client config for ${os} ==="
    sudo cat "/etc/wireguard/client_${os_lower}.conf"
    echo ""
    
    IP_COUNTER=$((IP_COUNTER + 1))
done


# !! Make sure the correct public-private key pairs !!


# Packet Forwarding
if ! grep -q "net.ipv4.ip_forward = 1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p


sudo wg show all