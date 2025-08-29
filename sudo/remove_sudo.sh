#!/usr/bin/env bash
set -e

# Ensure .env exists
if [ ! -f .env ]; then
  echo "❌ .env file not found!"
  exit 1
fi

# Load username from .env
set -a
source .env
set +a

TARGET="$NORMAL_USER"

echo "==> Removing $TARGET from sudo group..."
sudo gpasswd -d "$TARGET" sudo || true

echo "==> Clearing sudo authentication cache..."
sudo -k
sudo rm -rf "/var/lib/sudo/$TARGET" 2>/dev/null || true

echo "✅ Done. $TARGET should no longer have sudo privileges."


# Optional: reboot system
read -p "Reboot now? (y/N): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  echo "🔄 Rebooting..."
  sudo reboot
fi

# Show remaining sudo privileges for sanity check
sudo -l