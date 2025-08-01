#!/bin/bash

# Explicit path to your real home, not /root
log_path="/home/$USER/Documents/cuse_log.txt"

# 🌀 Phase 1: Check /dev/cuse and log status
echo "CUSE check initiated at $(date)" >> "$log_path"

if [ -e /dev/cuse ]; then
  perms=$(stat -c "%a" /dev/cuse)

  if [ "$perms" != "777" ]; then
    echo "Incorrect permissions: $perms — realigning CUSE boundary..." >> "$log_path"
    sudo chmod 777 /dev/cuse
    echo "Permissions updated to 777 at $(date)" >> "$log_path"
    ls -l /dev/cuse >> "$log_path"
  else
    echo "/dev/cuse already aligned with 777 permissions." >> "$log_path"
  fi
else
  echo "/dev/cuse not present at $(date)" >> "$log_path"
fi

# 🌱 Phase 2: Ensure log file exists if it wasn’t there before
if [ ! -f "$log_path" ]; then
  echo "Log boundary not present — crafting cuse_log.txt at $(date)" > "$log_path"
fi
