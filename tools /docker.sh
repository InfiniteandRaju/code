#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${BLUE}DOCKER MANAGER${WHITE} ]${NC}"

echo -e "${PURPLE}   [1] Install Docker"
echo -e "${PURPLE}   [2] Uninstall Docker"
echo -e ""
read -p "   Select → " opt

if [ "$opt" == "1" ]; then
    echo -e "${CYAN}   Installing Docker...${NC}"
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    systemctl enable --now docker
    echo -e "${GREEN}   Docker Installed.${NC}"
elif [ "$opt" == "2" ]; then
    echo -e "${RED}   Uninstalling Docker...${NC}"
    apt-get remove docker-ce docker-ce-cli containerd.io -y
    echo -e "${GREEN}   Docker Removed.${NC}"
fi
