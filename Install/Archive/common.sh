#!/bin/bash

# Firefox
cp config/profiles.ini "$USER_HOME/.mozilla/firefox/profiles.ini"
rm -rf "$USER_HOME/.mozilla/firefox/"*.default-release

# pyenv
curl https://pyenv.run | bash

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

