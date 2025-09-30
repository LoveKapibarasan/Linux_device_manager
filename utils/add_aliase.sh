#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Import functions
source "$SCRIPT_DIR/../util.sh"

USER_HOME=$(get_user_home)
ZSHRC="$USER_HOME/.zshrc"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ALIAS_FILE="$SCRIPT_DIR/aliases.csv"

if [ ! -f "$ALIAS_FILE" ]; then
  echo "aliases.csv not found in $SCRIPT_DIR"
  exit 1
fi

while IFS=, read -r NAME CMD; do
  # Skip empty lines or lines starting with '#'
  [ -z "$NAME" ] && continue
  [[ "$NAME" =~ ^# ]] && continue

  if grep -q "alias $NAME=" "$ZSHRC"; then
    echo "Alias '$NAME' already exists in $ZSHRC."
  else
    # Add a blank line
    echo >> "$ZSHRC"-
    echo "alias $NAME='$CMD'" >> "$ZSHRC"
    echo "Added alias '$NAME' to $ZSHRC."
  fi
done < "$ALIAS_FILE"
