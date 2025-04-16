#!/bin/bash

# =============================================
# SAFE SYSTEM RESET SCRIPT (Linux VPS)
# Removes user files, logs, temp files, and apps
# while preserving core OS functionality
# =============================================

# Debug mode
set -x

# Run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ This script must be run as root!" >&2
  exit 1
fi

# Network check
if ! ping -c 1 google.com &>/dev/null; then
  echo "❌ Network not available!"
  exit 1
fi

# ---- CONFIGURATION ----
REINSTALL_PACKAGES="openssh-server docker.io nodejs npm git ufw"
PRESERVE_PATHS="/etc/ssh/sshd_config,/home/backup"

# ---- WARNING ----
echo "⚡ WARNING: This will DELETE most files on this server!"
read -p "Type 'RESET' to confirm: " confirmation

if [ "$confirmation" != "RESET" ]; then
  echo "✅ Aborted. No changes made."
  exit 0
fi

# ---- PHASE 1: Backup ----
echo "[1/4] Backing up preserved paths..."
mkdir -p /tmp/preserved_files || {
  echo "❌ Failed to create backup directory"
  exit 1
}

IFS=',' read -ra PATHS <<< "$PRESERVE_PATHS"
for path in "${PATHS[@]}"; do
  if [ -e "$path" ]; then
    cp -rv "$path" /tmp/preserved_files/ || {
      echo "❌ Failed to backup $path"
      exit 1
    }
  fi
done

# ---- PHASE 2: Cleanup ----
echo "[2/4] Cleaning system..."

# Stop services safely
for service in $(systemctl list-units --type=service --no-legend | awk '{print $1}' | grep -Ev 'systemd|dbus|udev'); do
  systemctl stop "$service" || echo "⚠️ Couldn't stop $service"
done

# Safer file removal
exclude=("etc" "boot" "dev" "proc" "sys" "tmp" "run" "var")
for item in /*; do
  should_delete=true
  for excl in "${exclude[@]}"; do
    if [[ "$item" == "/$excl" ]]; then
      should_delete=false
      break
    fi
  done
  if $should_delete; then
    echo "Removing: $item"
    rm -rf --no-preserve-root "$item" || echo "⚠️ Couldn't remove $item"
  fi
done

# Clean other locations
for dir in /var/log /tmp /root /home /var/cache /var/lib/apt/lists; do
  [ -d "$dir" ] && rm -rf "$dir"/* || echo "⚠️ $dir not found"
done

# ---- PHASE 3: Reinstall ----
echo "[3/4] Reinstalling packages..."

# Update package lists with retry
for i in {1..3}; do
  apt-get update && break
  sleep 5
done || {
  echo "❌ Failed to update packages"
  exit 1
}

# Install packages
apt-get install --reinstall -y $REINSTALL_PACKAGES || {
  echo "❌ Failed to install packages"
  exit 1
}

# ---- PHASE 4: Restore ----
echo "[4/4] Restoring preserved paths..."
if [ -d /tmp/preserved_files ]; then
  cp -rv /tmp/preserved_files/* / || {
    echo "⚠️ Some files couldn't be restored"
  }
  rm -rf /tmp/preserved_files
fi

echo "✅ Reset complete!"
