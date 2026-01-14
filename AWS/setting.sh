
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

sudo apt install sniproxy

# Syntax Check
sudo sniproxy -c /etc/sniproxy.conf -f
sudo systemctl restart sniproxy

# !! Notes !!
## Use external DNS server for its own DNS resolution
## You may need to make this immutable
sudo vim /etc/resolv.conf

# sudo: unable to resolve host ip-xxx-xxx-xxx-xxx
hostname
sudo vim /etc/hosts # Add line: 127.0.1.1   ip-xxx-xxx-xxx-xxx
