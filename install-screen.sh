#!/bin/bash

# Update package list
sudo apt update

# Install screen
sudo apt install -y screen

# Check if screen is installed
if command -v screen &>/dev/null; then
    echo "Screen has been successfully installed!"
else
    echo "There was an error installing screen."
fi
