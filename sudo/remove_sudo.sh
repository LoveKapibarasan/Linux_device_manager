#!/usr/bin/env bash
set -e

# Load username from .env
set -a
source .env
set +a

TARGET="$NORMAL_USER"

echo "==> Removing $TARGET from sudo group..."
sudo gpasswd -d "$TARGET" sudo

echo "==> Clearing sudo authentication cache..."
sudo -k                       # invalidate current timestamp
sudo rm -rf /var/lib/sudo/$TARGET 2>/dev/null || true

echo "✅ Done. $TARGET should no longer have sudo privileges."

sudo -l
