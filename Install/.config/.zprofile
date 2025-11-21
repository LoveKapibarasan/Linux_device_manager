if [ -f "$HOME/.shellprofile" ]; then
  source "$HOME/.shellprofile"
else
  echo "No .shellprofile found in home directory."
fi

if [ -f ~/.zshrc ]; then
  source ~/.zshrc
else
  echo "No .zshrc found in home directory."
fi

if [[ -z $SSH_CONNECTION ]] && [[ -z $DISPLAY ]] && [[ -z $WAYLAND_DISPLAY ]]; then
  if command -v Hyprland >/dev/null 2>&1; then
    exec Hyprland
  elif command -v sway >/dev/null 2>&1; then
    exec dbus-run-session sway
  else
    echo "Neither Hyprland nor Sway is installed."
    exec bash
  fi
fi

