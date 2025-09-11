#!/bin/bash
set -e
if command -v apt >/dev/null; then
    apt update && apt -y upgrade && apt -y autoremove
elif command -v pacman >/dev/null; then
    pacman -Syu --noconfirm
fi