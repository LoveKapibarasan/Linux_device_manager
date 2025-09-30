#!/bin/bash
# add-functions.sh
# Append functions defined in *.sh files under ~/functions into ~/.zshrc
# Skip if the function already exists in ~/.zshrc

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Import functions
source "$SCRIPT_DIR/../util.sh"

USER_HOME=$(get_user_home)
ZSHRC="$USER_HOME/.zshrc"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FUNCDIR="$SCRIPT_DIR/functions"

# Check if the functions directory exists
if [ ! -d "$FUNCDIR" ]; then
  echo "Error: $FUNCDIR not found"
  exit 1
fi

for file in "$FUNCDIR"/*.sh; do
  [ -e "$file" ] || continue

  # Extract function names (lines ending with ())
  funcs=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)' "$file" | sed 's/().*//')

  for f in $funcs; do
    # Check if the function is already in .zshrc
    if grep -q "^[[:space:]]*$f()" "$ZSHRC"; then
      echo "skip: $f (already in .zshrc)"
    else
      # Add a blank line
      echo >> "$ZSHRC"
      echo "add: $f from $file"
      # Extract the function block and append it to .zshrc
      awk "/^$f[[:space:]]*\\(\\)/,/^}/" "$file" >> "$ZSHRC"
      echo >> "$ZSHRC"
    fi
  done
done


