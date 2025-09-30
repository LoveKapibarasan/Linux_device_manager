#!/bin/bash

source ../util.sh
root_check

USER_HOME=$(get_user_home)

# ZSH
chsh -s $(which zsh)
cp config/.zprofile "$USER_HOME/.zprofile"
cp config/.zshrc "$USER_HOME/.zshrc"

# fcitx 5
# 1. /etc/environment
sudo cp config/environment /etc/environment

# Vim
echo 'set clipboard=unnamedplus' > ~/.vimrc
## Neovim
git clone -o upstream https://github.com/neovim/neovim "${USER_HOME}/neovim"
cd "${USER_HOME}/neovim"
make CMAKE_BUILD_TYPE=Release
sudo make install
git clone https://github.com/folke/lazy.nvim.git \
  "${USER_HOME}/.local/share/nvim/lazy/lazy.nvim"
mkdir -p "$USER_HOME/.config/nvim"
cp config/init.lua "$USER_HOME/.config/nvim/init.lua"

cd -
# 指定ディレクトリ以下の全リポジトリで remote origin を upstream にリネームする

BASE_DIR="${1:-$HOME/.local/share/}"

find "$BASE_DIR" -type d -name ".git" | while read -r gitdir; do
  repo_dir="$(dirname "$gitdir")"
  echo "Processing: $repo_dir"

  cd "$repo_dir" || continue

  # remote origin があるか確認
  if git remote | grep -q "^origin$"; then
    echo "Renaming origin -> upstream"
    git remote rename origin upstream
  else
    echo "No origin found in $repo_dir"
  fi
done


# WM
cp config/hyprland.conf "$USER_HOME/.config/hypr/hyprland.conf"
cp config/config "$USER_HOME/.config/sway/config"

# Firefox
cp config/profiles.ini "$USER_HOME/.mozilla/firefox/profiles.ini"
rm -rf "$USER_HOME/.mozilla/firefox/"*.default-release


# FortVPN
echo "openfortivpn"
read -p "Username: " username
echo
read -p "Password: " password
echo

cat <<EOF | sudo tee -a /etc/openfortivpn/config > /dev/null
host = sslvpn.oth-regensburg.de
port = 443
realm = vpn-default
trusted-cert = 364fb4fa107e591626b3919f0e7f8169e9d2097974f3e3d55e56c7c756a1f94a
username = $username
password = $password
EOF
