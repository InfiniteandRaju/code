#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${BLUE}TAILSCALE VPN SETUP${WHITE} ]${NC}"

echo -e "${CYAN}   Installing Tailscale...${NC}"
curl -fsSL https://tailscale.com/install.sh | sh

echo -e "${GREEN}   Installation done.${NC}"
echo -e "${YELLOW}   Starting authentication...${NC}"
sudo tailscale up

echo -e "${GREEN}   Setup Complete.${NC}"
read -p "   Press Enter to return..."
