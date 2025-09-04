#!/usr/bin/env bash

# Go to a directory where you want to store the ISO
cd ~/Downloads

# Download the latest Arch Linux ISO from an official mirror
wget https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso

lsblk

sudo dd if=archlinux-x86_64.iso of=/dev/sd<a> bs=4M status=progress oflag=sync

sudo eject /dev/sd<a>
