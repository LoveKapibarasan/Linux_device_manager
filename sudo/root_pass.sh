#!/usr/bin/env bash
# This script generates a random root password (16 characters) 
# and sets it for the root account, then saves it into a text file on USB.

set -euo pipefail

# ======================
# Settings
# ======================
: "${PW_LENGTH:=16}"                          # Password length
: "${CHARSET:=A-Za-z0-9!@#%^+=:_.,-}"         # Allowed characters
TARGET_DIR="${1:-}"                           # USB directory (first arg)
TARGET_FILE="${2:-root_pass.txt}"             # Output file (second arg, optional)

if [[ $EUID -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [[ -z "${TARGET_DIR}" ]]; then
  echo "Usage: $0 <USB directory> [output filename]" >&2
  exit 1
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Target directory does not exist: ${TARGET_DIR}" >&2
  exit 1
fi

# ======================
# /etc/shadow explanation
# ======================
# Linux stores user account password hashes in /etc/shadow
# - Each line corresponds to a user account
# - Format: username:encrypted-password:other-fields...
# - Only root can read this file (mode 600, owner root:root)
# - This script modifies the root entry by calling `chpasswd`,
#   which safely updates the hash inside /etc/shadow.

# ======================
# Generate password
# ======================
generate_password() {
  if command -v openssl >/dev/null 2>&1; then
    LC_ALL=C openssl rand -base64 64 | tr -dc "${CHARSET}" | head -c "${PW_LENGTH}"
  else
    LC_ALL=C tr -dc "${CHARSET}" </dev/urandom | head -c "${PW_LENGTH}"
  fi
}

PW="$(generate_password)"

if [[ -z "${PW}" || ${#PW} -lt ${PW_LENGTH} ]]; then
  echo "Password generation failed." >&2
  exit 1
fi

# ======================
# Update root password
# ======================
printf 'root:%s\n' "${PW}" | chpasswd

# ======================
# Save to USB
# ======================
OUT_PATH="${TARGET_DIR%/}/${TARGET_FILE}"
echo "${PW}" > "${OUT_PATH}"

echo "Root password updated and saved to: ${OUT_PATH}"
