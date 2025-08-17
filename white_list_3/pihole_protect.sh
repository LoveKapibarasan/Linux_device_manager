#!/usr/bin/env bash

# Pi-hole lockdown script
# Execute as root: sudo bash lockdown_pihole.sh

set -e

PIHOLE_CONF_DIR="/etc/pihole"
BACKUP_DIR="/root/pihole_backup"
PASSWORD_FILE="$BACKUP_DIR/pihole_ui_password.txt"

echo "[1] Backing up Pi-hole config -> $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -a "$PIHOLE_CONF_DIR" "$BACKUP_DIR"

echo "[2] Set strict permissions so only root can modify Pi-hole configs"
chown -R root:root "$PIHOLE_CONF_DIR"
chmod -R go-rwx "$PIHOLE_CONF_DIR"

echo "[3] Lock DNS configuration (systemd-resolved.conf)"
DNS_CONF="/etc/systemd/resolved.conf"
chown root:root "$DNS_CONF"
chmod 600 "$DNS_CONF"

echo "[4] Lock systemd override so DNS settings cannot be modified"
systemctl mask systemd-resolved.service

echo "[5] Generate strong random WebUI password..."
RANDOM_PASS="$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+' </dev/urandom | head -c 32)"
printf '%s\n' "$RANDOM_PASS"
sudo pihole setpassword $RANDOM_PASS
echo "$RANDOM_PASS" > "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"
echo "New Pi-hole password saved to: $PASSWORD_FILE"

echo "[6] Prevent non-root users from uninstalling Pi-hole"
chmod 700 /usr/local/bin/pihole

echo done.
echo "Pi-hole lockdown is complete."
