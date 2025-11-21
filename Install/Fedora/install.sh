#!/bin/bash

sudo dnf update -y && sudo dnf upgrade

sudo dnf remove firefox
rm -rf ~/.mozilla

sudo dnf install git git-lfs sqlite3 -y


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


# Root
su -
passwd
# !! Wheel !!
gpasswd -d user wheel