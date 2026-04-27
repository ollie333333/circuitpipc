#!/bin/bash

CONFIG="/boot/firmware/config.txt"
BACKUP="/boot/firmware/config.txt.bak"

BOOT_SOUND="/home/pi/boot.wav"
SHUT_SOUND="/home/pi/shutdown.wav"

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
echo "        Circuit Pi PC Installer"
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

# Add config lines safely
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
# 🎨 MOTD
# =========================

echo -e "${BLUE}Installing terminal UI...${NC}"

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
# 🔊 BOOT SOUND
# =========================

echo -e "${BLUE}Setting up boot sound...${NC}"

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
# 🔊 SHUTDOWN SOUND
# =========================

echo -e "${BLUE}Setting up shutdown sound...${NC}"

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

# Enable services
systemctl daemon-reload
systemctl enable boot-sound.service
systemctl enable shutdown-sound.service

echo ""
echo -e "${GREEN}✔ FULL INSTALL COMPLETE${NC}"

echo -e "${CYAN}"
echo "🔊 Audio system ready"
echo "🔘 Power button enabled"
echo "🎨 Terminal UI installed"
echo "🎵 Boot + shutdown sounds ready"
echo -e "${NC}"

echo -e "${BLUE}Place your sound files here:${NC}"
echo "/home/pi/boot.wav"
echo "/home/pi/shutdown.wav"

echo -e "${GREEN}Then reboot:${NC} sudo reboot"
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
