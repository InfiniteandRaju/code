#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${CYAN}SOFTWARE INSTALLER${WHITE} ]${NC}"

echo -e "${PURPLE}   [1] Install Java (JDK 17)"
echo -e "${PURPLE}   [2] Install Node.js (v20)"
echo -e "${PURPLE}   [3] Install Python 3 + Pip"
echo -e ""
read -p "   Select → " opt

case $opt in
    1)
        apt update && apt install -y openjdk-17-jdk openjdk-17-jre
        echo -e "${GREEN}   Java 17 Installed.${NC}"
        ;;
    2)
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        apt install -y nodejs
        echo -e "${GREEN}   Node.js 20 Installed.${NC}"
        ;;
    3)
        apt update && apt install -y python3 python3-pip
        echo -e "${GREEN}   Python 3 Installed.${NC}"
        ;;
esac
