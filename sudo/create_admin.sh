#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Check if USER and PASSWORD are set
if [ -z "$USER" ] || [ -z "$PASSWORD" ]; then
    echo "USER or PASSWORD variable not set in .env file."
    exit 1
fi

# Create the new user with home directory
sudo useradd -m "$USER"

# Set the password for the new user
echo "$USER:$PASSWORD" | sudo chpasswd

# Add the new user to the sudo group
sudo usermod -aG sudo "$USER"

echo "User '$USER' created and added to sudo group successfully."
