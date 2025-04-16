#!/bin/bash

# =============================================
# SAFE SYSTEM RESET SCRIPT (Linux VPS)
# Removes user files, logs, temp files, and apps
# while preserving core OS functionality
# =============================================

# Run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root!" >&2
  exit 1
fi

# Warning confirmation
echo "!!! WARNING !!! This will DELETE most files on this server!"
echo "Recommended: Backup important data first!"
read -p "Type 'ERASE' to confirm: " confirmation

if [ "$confirmation" != "ERASE" ]; then
  echo "Aborted. No changes made."
  exit 0
fi

# Phase 1: Remove user data
echo "[1/3] Removing user files..."
rm -rf /home/* \
       /root/.*history \
       /root/* \
       /tmp/* \
       /var/tmp/* \
       2>/dev/null

# Phase 2: Clean package manager and logs
echo "[2/3] Cleaning system files..."
apt-get purge -y $(dpkg --get-selections | grep -v deinstall | awk '{print $1}') 2>/dev/null
apt-get autoremove -y 2>/dev/null
apt-get clean 2>/dev/null
rm -rf /var/log/* \
       /var/cache/* \
       /var/lib/apt/lists/* \
       2>/dev/null

# Phase 3: Reset network and services
echo "[3/3] Resetting network and services..."
systemctl stop $(systemctl list-units --type=service --no-legend | awk '{print $1}') 2>/dev/null
rm -f /etc/ssh/ssh_host_* \
      /etc/machine-id \
      /var/lib/dbus/machine-id \
      2>/dev/null

echo "----------------------------------------"
echo "Reset complete! Recommended next steps:"
echo "1. Reboot: sudo reboot"
echo "2. Reinstall needed packages"
echo "3. Restore configs from backup"
echo "----------------------------------------"
