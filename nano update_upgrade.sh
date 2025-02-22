#!/bin/bash
# This script will update and upgrade the system

echo "Updating package list..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt upgrade -y

echo "Update and upgrade complete!"
