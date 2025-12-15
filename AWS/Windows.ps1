# Windows
# Install Wireguard
# Copy and Paste client.conf then activate
# Daemon WireGuard
t_name=
& "C:\Program Files\WireGuard\wireguard.exe" /installtunnelservice "C:\Program Files\WireGuard\Data\Configurations\$t_name.conf.dpapi"


# SSH (pre-installed)
USERNAME=user
HOST=
PORT=22
ssh "${USERNAME}@${HOST}" -p $PORT