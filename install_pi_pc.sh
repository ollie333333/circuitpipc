#!/bin/bash

CONFIG="/boot/firmware/config.txt"
BACKUP="/boot/firmware/config.txt.bak"

BOOT_SOUND="/home/pi/boot.wav"
SHUT_SOUND="/home/pi/shutdown.wav"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

clear

echo -e "${CYAN}"
echo "   ██████╗ ██╗██████╗  ██████╗██╗   ██╗██╗████████╗"
echo "  ██╔════╝ ██║██╔══██╗██╔════╝██║   ██║██║╚══██╔══╝"
echo "  ██║      ██║██████╔╝██║     ██║   ██║██║   ██║   "
echo "  ██║      ██║██╔══██╗██║     ██║   ██║██║   ██║   "
echo "  ╚██████╗ ██║██║  ██║╚██████╗╚██████╔╝██║   ██║   "
echo "   ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   "
echo ""
echo "        ⚡ Circuit Pi PC Installer ⚡"
echo -e "${NC}"

sleep 1

# Root check
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Run with:${NC} sudo ./install_pi_pc.sh"
  exit 1
fi

echo -e "${GREEN}✔ Running as root${NC}"

# Backup config
cp "$CONFIG" "$BACKUP"
echo -e "${GREEN}✔ Config backup created${NC}"

# Add config safely
add_line() {
  LINE="$1"
  if ! grep -Fxq "$LINE" "$CONFIG"; then
    echo "$LINE" >> "$CONFIG"
    echo -e "${CYAN}➕ $LINE${NC}"
  else
    echo -e "${GREEN}✔ Exists: $LINE${NC}"
  fi
}

echo -e "${BLUE}Applying hardware config...${NC}"

add_line "dtparam=audio=off"
add_line "dtoverlay=pwm-2chan,pin=18,func=2"
add_line "dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up"

# =========================
# 🎨 MOTD (login banner)
# =========================

echo -e "${BLUE}Installing terminal banner...${NC}"

cat << "EOF" > /etc/motd
   ██████╗ ██╗██████╗  ██████╗██╗   ██╗██╗████████╗
  ██╔════╝ ██║██╔══██╗██╔════╝██║   ██║██║╚══██╔══╝
  ██║      ██║██████╔╝██║     ██║   ██║██║   ██║   
  ██║      ██║██╔══██╗██║     ██║   ██║██║   ██║   
  ╚██████╗ ██║██║  ██║╚██████╗╚██████╔╝██║   ██║   
   ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   

        ⚡ Circuit Pi PC ⚡
     GPIO Audio • AI • Robotics

Status: ONLINE
EOF

chmod -x /etc/update-motd.d/* 2>/dev/null

# =========================
# 🔊 COPY SOUND FILES
# =========================

echo -e "${BLUE}Installing sound files...${NC}"

if [ -f "$SCRIPT_DIR/boot.wav" ]; then
  cp "$SCRIPT_DIR/boot.wav" "$BOOT_SOUND"
  chown pi:pi "$BOOT_SOUND"
  echo -e "${GREEN}✔ boot.wav installed${NC}"
else
  echo -e "${RED}⚠ boot.wav missing in repo${NC}"
fi

if [ -f "$SCRIPT_DIR/shutdown.wav" ]; then
  cp "$SCRIPT_DIR/shutdown.wav" "$SHUT_SOUND"
  chown pi:pi "$SHUT_SOUND"
  echo -e "${GREEN}✔ shutdown.wav installed${NC}"
else
  echo -e "${RED}⚠ shutdown.wav missing in repo${NC}"
fi

# =========================
# 🔊 BOOT SOUND SERVICE
# =========================

cat << EOF > /etc/systemd/system/boot-sound.service
[Unit]
Description=Boot Sound
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/aplay $BOOT_SOUND
User=pi

[Install]
WantedBy=multi-user.target
EOF

# =========================
# 🔊 SHUTDOWN SOUND SERVICE
# =========================

cat << EOF > /etc/systemd/system/shutdown-sound.service
[Unit]
Description=Shutdown Sound
DefaultDependencies=no
Before=shutdown.target reboot.target halt.target

[Service]
Type=oneshot
ExecStart=/usr/bin/aplay $SHUT_SOUND
RemainAfterExit=true
User=pi

[Install]
WantedBy=halt.target reboot.target shutdown.target
EOF

systemctl daemon-reload
systemctl enable boot-sound.service
systemctl enable shutdown-sound.service

# =========================
# DONE
# =========================

echo ""
echo -e "${GREEN}✔ INSTALL COMPLETE${NC}"

echo -e "${CYAN}"
echo "🔊 PWM Audio: ENABLED"
echo "🔘 Power Button: ENABLED"
echo "🎵 Boot + Shutdown Sounds: INSTALLED"
echo "🎨 Terminal UI: ACTIVE"
echo -e "${NC}"

echo -e "${BLUE}Reboot with:${NC} sudo reboot"
