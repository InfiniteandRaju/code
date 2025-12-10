#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${YELLOW}SWAP RAM MANAGER${WHITE} ]${NC}"

echo -e "${GRAY}   Current Swap:${NC}"
free -h | grep Swap

echo -e ""
read -p "   Enter Swap Size (e.g. 2G, 4G): " SIZE

if [[ -z "$SIZE" ]]; then echo "Invalid size."; exit; fi

echo -e "${CYAN}   Creating $SIZE Swap file...${NC}"
fallocate -l $SIZE /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab

echo -e "${GREEN}   Swap Created Successfully!${NC}"
