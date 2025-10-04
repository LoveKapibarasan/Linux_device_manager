#!/bin/bash

source ../util.sh

# Hostname 
read -p "Enter hostname: " hostname
echo "${hostname}" > /etc/hostname

echo "$hostname" | sudo tee /etc/hostname

# ★ Hosts
sudo rm -rf /etc/hosts
sudo touch /etc/hosts
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${HOSTNAME}
EOF


# Locale
## Candidates
if is_command apt || is_command pacman;then
    # localization settings
    sudo sed -i 's/^# *\(de_DE.UTF-8 UTF-8\)/\1/' /etc/locale.gen
    sudo sed -i 's/^# *\(ja_JP.UTF-8 UTF-8\)/\1/' /etc/locale.gen
    sudo locale-gen
fi
## Default
if is_command apt;then
        sudo update-locale LANG=en_GB.UTF-8
elif is_command pacman;then
        echo 'LANG=en_GB.UTF-8' | sudo tee /etc/locale.conf
fi

locale -a

# Timezone
# sudo date -s "YYYY-MM-DD HH:MM:SS"
echo "Select timezone:"
echo "1) Tokyo"
echo "2) Berlin"
read -p "Enter number: " TZ_CHOICE

case "$TZ_CHOICE" in
  1) TIMEZONE="Asia/Tokyo" ;;
  2) TIMEZONE="Europe/Berlin" ;;
  *) echo "Invalid choice, defaulting to Tokyo"; TIMEZONE="Asia/Tokyo" ;;
esac

if is_command apt || is_command pacman;then
    sudo timedatectl set-timezone $TIMEZONE
fi
# Keyboard
if is_command apt;then
        read -p "Enter keyboard layout (jp, de): " KEYMAP
        sed -i "s/^XKBLAYOUT=.*/XKBLAYOUT=\"${KEYMAP}\"/" /etc/default/keyboard

elif is_command pacman;then
        read -p "Enter keyboard layout (jp106, de): " KEYMAP
        echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
        ## Reload
        sudo localectl set-keymap de
        sudo localectl status
fi

# Residence = Wohnsitz

read -p "Enter your residence (JP, DE): " COUNTRY

## Country for Wifi
echo -e "[device]\nwifi.country=${COUNTRY}" | sudo tee /etc/NetworkManager/conf.d/wifi-country.conf
cat /etc/NetworkManager/conf.d/wifi-country.conf
sudo systemctl restart NetworkManager

# MIME
ZATHURA=$(ls /usr/share/applications/ | grep zathura)
xdg-mime default "$ZATHURA" application/pdf
xdg-mime query default application/pdf

sudo cp config/nvim.desktop /usr/share/applications/ 
# text/*のMIMEタイプを全て取得してnvimに設定
grep '^text/' /etc/mime.types | awk '{print $1}' | sort -u | while read mime; do
    xdg-mime default nvim.desktop "$mime"
done

# URL
xdg-mime default qutebrowser.desktop x-scheme-handler/http
xdg-mime default qutebrowser.desktop x-scheme-handler/https

xdg-settings set default-web-browser qutebrowser.desktop

xdg-settings get default-web-browser
# Reload and Test
update-desktop-database ~/.local/share/applications/
xdg-open http://example.com
