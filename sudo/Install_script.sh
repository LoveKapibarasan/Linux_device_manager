#!/usr/bin/env bash
set -euo pipefail # three safety options
IFS=$'\n\t'

USER_NAME=${SUDO_USER:-${USER}}
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)

run_as_user() {
  sudo -u "$USER_NAME" env XDG_RUNTIME_DIR="/run/user/$(id -u "$USER_NAME")" HOME="$USER_HOME" "$@"
}

# 1. Disable GNOME on-screen keyboard
sudo apt purge squeekboard
sudo apt autoremove --purge


# 2. Install fcitx5 + mozc
sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt install -y fcitx5 fcitx5-mozc fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-modules im-config
run_as_user im-config -n fcitx5

# 3. Purge text editor, default programming editor
sudo apt purge -y leafpad mousepad pluma gedit kate geany thonny mu-editor

# 4. Create a template file
mkdir -p "$USER_HOME/Templates"
touch "$USER_HOME/Templates/Empty File"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Templates"

# 5. Purge Chromium, install Firefox
sudo apt purge -y chromium chromium-browser
sudo apt install -y firefox-esr
run_as_user xdg-settings set default-web-browser firefox-esr.desktop

# 6. Purge nano, install vim
sudo apt purge -y nano
sudo apt install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic

# 7. Install dev stack
sudo apt install -y git code python3 python3-pip gcc g++ texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended npm r-base openjdk-17-jdk postgresql


# 8. Set X11 as default(Advanced option)
sudo raspi-config

# 9. Remove backgrounds, set plain color
sudo find /usr/share/backgrounds -type f -name '*.png' -delete
sudo find /usr/share/rpd-wallpaper -type f -name '*.png' -delete
sudo dbus-launch gsettings set org.gnome.desktop.background picture-uri ''
sudo dbus-launch gsettings set org.gnome.desktop.background primary-color '#000000'

sudo reboot
