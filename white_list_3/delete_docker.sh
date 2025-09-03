docker rm -f pihole

sudo rm -rf /etc/systemd/system/pihole.service
sudo rm -rf /opt/pihole
sudo systemctl disable pihole.service
sudo systemctl stop pihole.service

systemctl status pihole.service
