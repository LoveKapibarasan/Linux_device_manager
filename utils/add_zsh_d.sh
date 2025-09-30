#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Import functions
source "$SCRIPT_DIR/../util.sh"


USER_HOME=$(get_user_home)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/zsh-d"
DST="$USER_HOME/.zshrc.d"

mkdir -p "$DST"

# copy zsh 
for file in "$SRC"/*.zsh; do
    [ -e "$file" ] || continue
    base=$(basename "$file")
    cp "$file" "$DST/$base"
    echo "Copied: $file -> $DST/$base"
done

echo "Done! All .zsh files copied to $DST"
