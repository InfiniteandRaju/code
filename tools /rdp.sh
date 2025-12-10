#!/bin/bash
# ==========================================
# RDP / DESKTOP INSTALLER
# Made By: Infinite21 & Staxxy Rai
# ==========================================

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

banner(){
    clear
    echo -e "${CYAN}   RDP INSTALLER${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

install_rdp(){
    banner
    echo -e "${WHITE}   [ ${YELLOW}INSTALLING XFCE4 GUI & XRDP${WHITE} ]${NC}"
    echo -e "${BLUE}   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}   Update packages...${NC}"
    sudo apt-get update -y -q
    
    echo -e "${CYAN}   Installing Desktop Environment (this takes time)...${NC}"
    sudo apt-get install -y xfce4 xfce4-goodies xrdp -q

    echo -e "${CYAN}   Configuring XRDP...${NC}"
    sudo systemctl enable xrdp
    sudo systemctl start xrdp
    echo "xfce4-session" > ~/.xsession
    sudo service xrdp restart

    echo -e "${GREEN}   Installation Complete!${NC}"
    echo -e "${WHITE}   Connect using Remote Desktop Connection using your IP.${NC}"
    echo -e "${WHITE}   Username: root (or your user) | Password: (your vps password)${NC}"
    echo -e ""
    read -p "   Press Enter to return..."
}

install_rdp
