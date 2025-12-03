
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# .env
source "${SCRIPT_DIR}/.env"

hostname -I
echo "Please ensure that the domain $DOMAIN is pointing to this server's IP address.(A record)"
nslookup $DOMAIN

# Certbot
sudo apt update
sudo apt install certbot -y

# Check if 80 port is free
if sudo lsof -i :80; then
    sudo lsof -i :80
    echo "Port 80 is in use. Please free the port and run the script again."
    exit 1
fi

# Turn off cloudflare proxy ( visitor → Cloudflare → server )

sudo certbot certonly --standalone -d $DOMAIN

# Set up automatic renewal(Default 90 days expiry)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test automatic renewal process
sudo certbot renew --dry-run