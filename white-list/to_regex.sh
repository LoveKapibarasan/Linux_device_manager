#!/bin/bash

# Script to convert a domain list into regex format
# Usage: ./to_regex.sh domains.txt > regex_blocklist.txt

input="$1"

if [ -z "$input" ]; then
  echo "Usage: $0 <domain list file>" >&2
  exit 1
fi

while read -r domain; do
  # Skip empty lines and lines starting with #
  [[ -z "$domain" || "$domain" =~ ^# ]] && continue

  # Escape dots in the domain and convert to regex
  regex="(^|\.)${domain//./\\.}$"
  echo "$regex"
done < "$input"
