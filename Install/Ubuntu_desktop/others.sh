#!/bin/bash

sudo snap install dbeaver-ce postgresql -y
sudo systemctl enable postgresql --now
