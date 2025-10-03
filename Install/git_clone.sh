#!/bin/bash
source ../../util.sh

non_root_check

git lfs install

read -p "Enter username: " username
echo
read -p "Enter email: " email
echo

cd 

git config --global user.name ""$username""
git config --global user.email ""$email""
git config --list

git clone git@github.com:LoveKapibarasan/Linux_device_manager.git
git clone git@github.com:LoveKapibarasan/utils_python.git
git clone git@github.com:LoveKapibarasan/kifs.git
git clone git@github.com:LoveKapibarasan/my_website.git
git clone git@github.com:LoveKapibarasan/enc-private.git

git clone git@github.com:LoveKapibarasan/shogihome.git
cd "${HOME}/shogihome"
git remote add origin upstream git@github.com:sunfish-shogi/shogihome.git
cd
