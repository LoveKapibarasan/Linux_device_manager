#!/bin/bash

ZSHRC="$HOME/.zshrc"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FUNCTIONS_DIR="$SCRIPT_DIR/scripts"

if [ ! -d "$FUNCTIONS_DIR" ]; then
  echo "Directory $FUNCTIONS_DIR not found"
  exit 1
fi

for file in "$FUNCTIONS_DIR"/*.sh; do
  [ -e "$file" ] || continue   # skip if no .sh files
  name="$(basename "$file" .sh)"

  if grep -q "alias $name=" "$ZSHRC"; then
    echo "Alias '$name' already exists in $ZSHRC."
  else
    echo "alias $name='$file'" >> "$ZSHRC"
    echo "Added alias '$name' for $file"
  fi
done

echo "Run 'source ~/.zshrc' to reload aliases."
