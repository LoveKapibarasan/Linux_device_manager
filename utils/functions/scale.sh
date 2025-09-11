scale() {
  local SCALE=${1:-1}
  local CONFIG="$HOME/.config/sway/config"

  if grep -q "^output \* scale" "$CONFIG"; then
    sed -i "s/^\(output \* scale \).*/\1$SCALE/" "$CONFIG"
  else
    echo "output * scale $SCALE" >> "$CONFIG"
  fi

  swaymsg reload
  echo "Set sway scale to $SCALE"
}