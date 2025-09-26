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

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=fcitx