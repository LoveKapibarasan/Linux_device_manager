#!/bin/bash

USB_MOUNT="/media/usb"
TOKEN_FILE="$USB_MOUNT/auth_token.gpg"
EXPECTED="LOGIN_OK"

# Prüfen, ob Datei vorhanden
if [ ! -f "$TOKEN_FILE" ]; then
  echo "Token file not found." >&2
  exit 1
fi

# Entschlüsseln
DECRYPTED=$(gpg --quiet --batch --yes --decrypt "$TOKEN_FILE" 2>/dev/null)

# Prüfen
if [ "$DECRYPTED" = "$EXPECTED" ]; then
  exit 0  # Erfolg
else
  echo "Decryption failed or invalid token." >&2
  exit 1  # Verweigern
fi
