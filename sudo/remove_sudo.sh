#!/usr/bin/env bash
set -euo pipefail

# Load variables from .env
set -a
source .env
set +a

if [[ -z "${NORMAL_USER:-}" ]]; then
    echo "NORMAL_USER is not set in .env"
    exit 1
fi

TARGET="$NORMAL_USER"

echo "Removing sudo privileges for: $TARGET"

# Remove from common sudo/admin groups
for g in sudo wheel admin; do
    if id -nG "$TARGET" | grep -qw "$g"; then
        sudo gpasswd -d "$TARGET" "$g" || true
    fi
done

# Remove user-specific sudoers files
sudo rm -f /etc/sudoers.d/"$TARGET" /etc/sudoers.d/"${TARGET}"_*

# Remove sudo authentication cache
sudo rm -rf /var/lib/sudo/"$TARGET" || true

# Check main sudoers file for direct entries
echo
echo "Checking /etc/sudoers for '$TARGET' entries..."
if sudo grep -E "^[^#].*\b$TARGET\b" /etc/sudoers; then
    echo "⚠️ Found entries above. Use 'sudo visudo' to remove them."
else
    echo "No direct entries found in /etc/sudoers."
fi

# Verify
echo
if sudo -l -U "$TARGET" &>/dev/null; then
    echo "❌ $TARGET STILL has sudo privileges."
else
    echo "✅ $TARGET no longer has sudo privileges."
fi
