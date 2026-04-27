#!/bin/bash

CONFIG="/boot/firmware/config.txt"
BACKUP="/boot/firmware/config.txt.bak"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

clear

# 🔥 ASCII ART (installer banner)
echo -e "${CYAN}"
echo "   ██████╗ ██╗██████╗  ██████╗██╗   ██╗██╗████████╗"
echo "  ██╔════╝ ██║██╔══██╗██╔════╝██║   ██║██║╚══██╔══╝"
echo "  ██║      ██║██████╔╝██║     ██║   ██║██║   ██║   "
echo "  ██║      ██║██╔══██╗██║     ██║   ██║██║   ██║   "
echo "  ╚██████╗ ██║██║  ██║╚██████╗╚██████╔╝██║   ██║   "
echo "   ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   "
echo ""
echo "        Circuit Pi PC Installer"
echo -e "${NC}"

sleep 1

echo -e "${BLUE}Checking permissions...${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root:${NC} sudo ./install_pi_pc.sh"
  exit 1
fi

echo -e "${GREEN}✔ Running as root${NC}"

# Backup config
echo -e "${BLUE}Backing up config.txt...${NC}"
cp "$CONFIG" "$BACKUP"
echo -e "${GREEN}✔ Backup created${NC}"

# Function to safely add lines
add_line() {
  LINE="$1"
  if grep -Fxq "$LINE" "$CONFIG"; then
    echo -e "${GREEN}✔ Exists:${NC} $LINE"
  else
    echo -e "${CYAN}➕ Adding:${NC} $LINE"
    echo "$LINE" >> "$CONFIG"
  fi
}

echo -e "${BLUE}Applying system configuration...${NC}"

add_line "dtparam=audio=off"
add_line "dtoverlay=pwm-2chan,pin=18,func=2"
add_line "dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up"

# =========================
# 🎨 SET CUSTOM MOTD
# =========================

echo -e "${BLUE}Installing Circuit terminal banner...${NC}"

cat << "EOF" > /etc/motd
   ██████╗ ██╗██████╗  ██████╗██╗   ██╗██╗████████╗
  ██╔════╝ ██║██╔══██╗██╔════╝██║   ██║██║╚══██╔══╝
  ██║      ██║██████╔╝██║     ██║   ██║██║   ██║   
  ██║      ██║██╔══██╗██║     ██║   ██║██║   ██║   
  ╚██████╗ ██║██║  ██║╚██████╗╚██████╔╝██║   ██║   
   ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   

        ⚡ Circuit Pi PC ⚡
     GPIO Audio • AI • Robotics

System: Raspberry Pi 3B+
Kernel: Bookworm
Status: ONLINE
EOF

# Disable default Debian MOTD scripts
chmod -x /etc/update-motd.d/* 2>/dev/null

echo -e "${GREEN}✔ Terminal banner installed${NC}"

echo ""
echo -e "${GREEN}✔ Setup complete!${NC}"

echo -e "${CYAN}"
echo "   🔊 PWM Audio Enabled (GPIO18)"
echo "   🔘 Power Button Enabled (GPIO3)"
echo "   🖥️ Custom Terminal UI Enabled"
echo -e "${NC}"

echo -e "${BLUE}Reboot required →${NC} sudo reboot"
