
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

# Test Server
sudo python3 -m http.server 80

# Note:  Turn off cloudflare proxy ( visitor → Cloudflare → server )

# Test from router
curl -v http://10.10.0.2/.well-known/acme-challenge/test
# Logs
sudo tail -100 /var/log/letsencrypt/letsencrypt.log

sudo certbot certonly --standalone -d $DOMAIN
# sudo certbot certonly --standalone --http-01-address 10.10.0.2 -d $DOMAIN
## Nginx
# sudo certbot certonly --webroot -w /var/www/html -d lovekapibarasan.org
# ワイルドカード証明書を取得
sudo certbot certonly --manual --preferred-challenges dns -d lovekapibarasan.org -d *.lovekapibarasan.org
# Add this entry
```
Type: TXT
Name: _acme-challenge
Content: xufdhsv
TTL: xmin
```

# Set up automatic renewal(Default 90 days expiry)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test automatic renewal process
sudo certbot renew --dry-run

# options-ssl-nginx.conf を作成
sudo tee /etc/letsencrypt/options-ssl-nginx.conf > /dev/null <<'EOF'
ssl_session_cache shared:le_nginx_SSL:10m;
ssl_session_timeout 1440m;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;
ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384";
EOF

# ssl-dhparams.pem を作成(2-3分)
sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
