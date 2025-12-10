#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${CYAN}SKYPORT PANEL INSTALLER${WHITE} ]${NC}"
echo -e ""
echo -e "${YELLOW}   Skyport is a modern game panel.${NC}"
echo -e "${GRAY}   This script will install Node.js and pull the latest Skyport build.${NC}"
echo -e ""
read -p "   Press Enter to begin installation..."

# Install Node
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs git

# Clone
cd /etc
git clone https://github.com/skyport-team/skyportd
cd panel
npm install

echo -e ""
echo -e "${GREEN}   Installation files downloaded to /etc/panel.${NC}"
echo -e "${YELLOW}   To finish: type 'npm run seed' then 'npm start'.${NC}"
