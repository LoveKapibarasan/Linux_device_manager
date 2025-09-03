
ls -l /etc/resolv.conf 

sudo vim /etc/resolv.conf
# only 'nameserver 127.0.0.1' is best

#=== NetworkManager ===
# 1.
sudo vim /etc/NetworkManager/NetworkManager.conf
# [main]
# dns=none
cat /etc/NetworkManager/NetworkManager.conf
# !!===Failed===!!


# 2. make file immutable
sudo chattr +i /etc/resolv.conf


#=== resolved ===
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved


# set password
sudo -s
cd /opt/pihole
echo "ADMIN_PASSWORD=$(openssl rand -base64 20)" | sudo tee .env
docker exec -it pihole pihole setpassword "$(grep ADMIN_PASSWORD .env | cut -d'=' -f2)"