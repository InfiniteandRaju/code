#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${BLUE}BLUEPRINT FRAMEWORK INSTALLER${WHITE} ]${NC}"

echo -e "${CYAN}   Installing dependencies...${NC}"
apt-get install -y git curl zip unzip tar

echo -e "${CYAN}   Downloading Blueprint...${NC}"
bash <(curl -s https://raw.githubusercontent.com/tehwat/blueprint/main/install.sh)

echo -e "${GREEN}   Done.${NC}"
read -p "   Press Enter to return..."
