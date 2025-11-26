#!/bin/bash

# . The name itself comes from an 1882 French play called Fédora by Victorien Sardou, written for actress Sarah Bernhardt. 


sudo dnf update -y && sudo dnf upgrade

sudo dnf remove firefox
rm -rf ~/.mozilla

# Basic
sudo dnf install git git-lfs sqlite3 vim -y


# Pihole
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
curl -sSL https://install.pi-hole.net | bash

# Cursor
# https://cursor.com/docs/cli/installation
curl https://cursor.com/install -fsS | bash

# Sublime-Text(subl)
# https://www.sublimetext.com/download
# Issue: 15.11.2025
# https://github.com/sublimehq/sublime_text/issues/6669
sudo rpm -i --nodigest sublime*.rpm


# Opera
# https://linuxcapable.com/install-opera-on-fedora-linux/
# Alt + p -> Default Search Engine: DuckDuckGo
sudo rpm --import https://rpm.opera.com/rpmrepo.key
sudo tee /etc/yum.repos.d/opera.repo <<RPMREPO
[opera]
name=Opera packages
type=rpm-md
baseurl=https://rpm.opera.com/rpm
gpgcheck=1
gpgkey=https://rpm.opera.com/rpmrepo.key
enabled=1
RPMREPO
sudo dnf install opera-stable -y

# Fcitx5
sudo dnf install fcitx5 fcitx5-mozc fcitx5-configtool fcitx5-qt fcitx5-gtk -y
imsettings-switch none
# 1. Open System Settings
# 2. Go to Virtual Keyboard
# 3. Choose Fcitx 5 from the list
# 4. Apply & log out / log in

# KDE Desktop Themas
# Setting -> Appearance
# https://fedoraproject.org/wiki/User_Guide_-_Customizing_the_Desktop#KDE
# 1. Earth Plasma: https://store.kde.org/p/1305216
# 2. Login: https://store.kde.org/p/1436554
LOGIN_THEMA=Infinity-SDDM
tar -xf ~/Downloads/*LOGIN_THEMA*.tar.*z
sudo mv *LOGIN_THEMA* /usr/share/sddm/themes/
sudo sed -i "s/^#*Current=.*/Current=${LOGIN_THEMA}/" /etc/sddm.conf
sudo dnf install kf5-plasma-devel kf5-kdeclarative-devel -y

# Root
su -
passwd
# !! Wheel !!
gpasswd -d user wheel