#!/bin/bash
# ==========================================
# CPANEL (CYBERPANEL) INSTALLER
# Made By: Infinite21 & Staxxy Rai
# ==========================================

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

banner(){
    clear
    echo -e "${CYAN}   CPANEL / CYBERPANEL INSTALLER${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
}

install_cpanel(){
    banner
    echo -e "${WHITE}   [ ${YELLOW}INSTALLATION WARNING${WHITE} ]${NC}"
    echo -e "${RED}   This will install CyberPanel (OpenLiteSpeed).${NC}"
    echo -e "${RED}   This requires a clean OS (Ubuntu 20.04/22.04).${NC}"
    echo -e ""
    read -p "   Press Enter to start installation or CTRL+C to cancel..."
    
    sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh)
}

install_cpanel
