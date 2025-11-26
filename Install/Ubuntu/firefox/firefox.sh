#!/bin/bash

# === SNAP version of firefox ===
cp ./user.js $HOME/snap/firefox/common/.mozilla/firefox/*default


# about:preferences#search
echo "Check the latest extension version"
sudo mkdir -p /var/snap/firefox/common/etc/firefox/policies/
sudo cp ./policies.json /var/snap/firefox/common/etc/firefox/policies/