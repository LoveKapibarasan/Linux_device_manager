
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# .env
source "${SCRIPT_DIR}/.env"

USERNAME=ubuntu
KEY_FILE=key.pem
KEY_PATH="${SCRIPT_DIR}/${KEY_FILE}"


git clone https://github.com/LoveKapibarasan/Linux_device_manager.git
# Inbound Rule: Open 53(DNS: TCP, UDP), 80(HTTP), 51820(UDP)


# Outside the ssh shell
scp -i "${KEY_PATH}" "$SCRIPT_DIR/.env"  "${USERNAME}@${DNS_IP}:/home/${USERNAME}/Linux_device_manager/white_list_6/"
scp -i "${KEY_PATH}" "$SCRIPT_DIR/../white_list_3/db/gravity_current.db" "${USERNAME}@${DNS_IP}:/home/${USERNAME}"

# Stop systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl mask systemd-resolved

# Open Port 2222
sudo vim /etc/ssh/sshd_config
# Add 'Port 22' and 'Port 2222'


# Permission Error
sudo chown -R $USER:$USER searxng/
