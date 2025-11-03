#!/bin/bash

sudo snap install dbeaver-ce postgresql rabbitmq-server -y
sudo systemctl enable postgresql --now
sudo systemctl enable rabbitmq-server --now

# server
sudo apt install remmina remmina-plugin-rdp -y

# Latex
sudo apt install texlive texlive-full -y
# magick
sudo apt install imagemagick-7.q16  -y

# R
sudo apt install r-base -y
## Rstudio
cd ~/Downloads
wget https://cran.rstudio.com/bin/linux/ubuntu/ -O Rstudio.deb
sudo apt install ./Rstudio.deb -y
cd


# Chrome
cd ~/Downloads
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y