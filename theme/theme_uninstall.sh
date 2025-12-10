#!/bin/bash
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; NC='\033[0m'

clear
echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${WHITE}   [ ${RED}THEME UNINSTALLER${WHITE} ]${NC}"
echo -e "${YELLOW}   This will attempt to build the panel production assets.${NC}"
echo -e ""
read -p "   Press Enter to confirm..."

cd /var/www/pterodactyl
php artisan view:clear
php artisan config:clear
yarn build:production

echo -e "${GREEN}   Theme reset complete.${NC}"
read -p "   Press Enter to return..."
