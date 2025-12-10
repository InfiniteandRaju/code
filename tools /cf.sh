#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${YELLOW}CLOUDFLARED TUNNEL${WHITE} ]${NC}"

if [ -f /usr/bin/cloudflared ]; then
    echo -e "${GREEN}   Cloudflared is already installed.${NC}"
else
    echo -e "${CYAN}   Installing Cloudflared...${NC}"
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared.deb
    rm cloudflared.deb
fi

echo -e "${BLUE}   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}   Paste your Cloudflare Tunnel Command below:${NC}"
echo -e "${GRAY}   (It usually starts with 'sudo cloudflared service install...')${NC}"
read -p "   Command → " token
eval "$token"

echo -e "${GREEN}   Tunnel Activated.${NC}"
read -p "   Press Enter to return..."
