
USERNAME="ubuntu"

sudo mv /home/$USERNAME/gravity_current.db /etc/pihole/gravity.db && sudo pihole -g
sudo systemctl stop systemd-resolved.service
sudo systemctl mask systemd-resolved.service

# https://docs.pi-hole.net/ftldns/configfile/?h=listeni#listeningmode
sudo sed -i 's/^listeningMode = .*/listeningMode = "ALL"/' /etc/pihole/pihole.toml