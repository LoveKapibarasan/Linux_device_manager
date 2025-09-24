#!/bin/bash

read -p "Enter username: " username

for f in /etc/sudoers /etc/sudoers.d/*; do
  [ -f "$f" ] || continue

  # Check
  if grep -q "$username" "$f"; then
    echo "=== File: $f ==="
    grep "takanori" "$f"
    read -p "Comment out these lines in $f? (y/n) " ans
    if [ "$ans" = "y" ]; then
      sudo sed -i -E '/takanori/ s/^/#/' "$f"
      echo "→ Updated $f"
    else
      echo "→ Skipped $f"
    fi
  fi
done

sudo visudo -c