#!/bin/bash


ZSHRC="$HOME/.zshrc"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FUNCTIONS_DIR="$SCRIPT_DIR/scripts"

if [ ! -d "$FUNCTIONS_DIR" ]; then
  echo "Directory $FUNCTIONS_DIR not found"
  exit 1
fi

# Add to PATH if not already there
if grep -q "$FUNCTIONS_DIR" "$ZSHRC"; then
  echo "$FUNCTIONS_DIR is already in PATH."
else
  echo "export PATH=\"$FUNCTIONS_DIR:\$PATH\"" >> "$ZSHRC"
  echo "Added $FUNCTIONS_DIR to PATH in $ZSHRC"
fi

echo "Run 'source ~/.zshrc' to reload your shell."

