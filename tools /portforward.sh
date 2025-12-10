#!/bin/bash
# ==========================================
# PORT FORWARDER
# Made By: Infinite21 & Staxxy Rai
# ==========================================

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

banner(){
    clear
    echo -e "${CYAN}   PORT FORWARDER${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
}

forward_port(){
    banner
    echo -e "${WHITE}   [ ${YELLOW}CONFIGURE PORT FORWARDING${WHITE} ]${NC}"
    echo -e "${BLUE}   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if ! command -v socat &> /dev/null; then
        echo -e "${CYAN}   Installing socat...${NC}"
        apt-get update && apt-get install socat -y -q
    fi

    echo -e ""
    read -p "   Enter Local Port (e.g. 80): " lport
    read -p "   Enter Remote IP (Target): " rip
    read -p "   Enter Remote Port (Target): " rport

    echo -e "${GREEN}   Forwarding $lport → $rip:$rport ...${NC}"
    echo -e "${YELLOW}   Keep this window open to keep the tunnel active.${NC}"
    socat TCP-LISTEN:$lport,fork TCP:$rip:$rport
}

forward_port
