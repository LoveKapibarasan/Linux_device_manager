docker rm -f pihole

sudo rm -rf /etc/systemd/system/pihole.service
sudo rm -rf /opt/pihole
sudo systemctl disable pihole.service
sudo systemctl stop pihole.service

systemctl status pihole.service


# delete link
sudo rm /etc/resolv.conf
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf
sudo systemctl enable --now systemd-resolved

sudo cat /etc/resolv.conf
# link again
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
