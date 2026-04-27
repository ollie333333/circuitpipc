#!/bin/bash

CONFIG="/boot/firmware/config.txt"
BACKUP="/boot/firmware/config.txt.bak"

echo "=== Circuit Pi PC Setup ==="

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./install_pi_pc.sh"
  exit 1
fi

# Backup config
echo "Backing up config.txt..."
cp $CONFIG $BACKUP

# Function to add line if missing
add_line() {
  LINE="$1"
  if grep -Fxq "$LINE" "$CONFIG"; then
    echo "✔ Already exists: $LINE"
  else
    echo "➕ Adding: $LINE"
    echo "$LINE" >> "$CONFIG"
  fi
}

echo "Applying audio + GPIO settings..."

add_line "dtparam=audio=off"
add_line "dtoverlay=pwm-2chan,pin=18,func=2"
add_line "dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up"

echo "Done."

echo "Reboot required for changes to take effect."
