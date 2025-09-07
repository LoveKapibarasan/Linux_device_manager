#!/bin/bash

# 0. Set root password
sudo passwd root

# 1. Add
adduser username

# 2. Delete
# ユーザーアカウントとホームディレクトリを削除
deluser --remove-home username

#=== Arch Linux ===
# 1.
sudo useradd -m -G wheel -s /bin/bash username
sudo passwd username

# 2.
sudo userdel -r username

