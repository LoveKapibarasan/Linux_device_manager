
# .env
set -a
source .env
set +a

USERNAME=ubuntu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY_FILE=key.pem
KEY_PATH="${SCRIPT_DIR}/${KEY_FILE}"

# Open 53(DNS: TCP, UDP), 80(HTTP)

scp -i "${KEY_PATH}" "$SCRIPT_DIR/../white_list_3/db/gravity_current.db" "${USERNAME}@${DNS_IP}:/home/${USERNAME}"
