# Made By - infinite21 
# ===========================================================

# --- COLORS & STYLING ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
WHITE='\033[1;37m'
GRAY='\033[1;30m'
NC='\033[0m'
BOLD='\033[1m'

# --- UTILS ---
pause(){ 
    echo -e ""
    echo -e "${GRAY}   [${WHITE}Press Enter to continue...${GRAY}]${NC}"
    read -p "" x
}

separator(){
    echo -e "${BLUE}   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ===================== BANNER =====================
banner(){
    clear
    echo -e "${CYAN}"
    echo -e "   ██╗   ██╗ █████╗ ██╗    ███╗   ██╗ ██████╗ ██████╗ ███████╗███████╗"
    echo -e "   ██║   ██║██╔══██╗██║    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔════╝"
    echo -e "   ██║   ██║███████║██║    ██╔██╗ ██║██║   ██║██║  ██║█████╗  ███████╗"
    echo -e "   ╚██╗ ██╔╝██╔══██║██║    ██║╚██╗██║██║   ██║██║  ██║██╔══╝  ╚════██║"
    echo -e "    ╚████╔╝ ██║  ██║██║    ██║ ╚████║╚██████╔╝██████╔╝███████╗███████║"
    echo -e "     ╚═══╝  ╚═╝  ╚═╝╚═╝    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝"
    echo -e "${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}             Made By : ${CYAN}Infinite21 ${WHITE} & ${GREEN} Staxxy Rai  ${PURPLE}      ║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# ===================== PANEL MENU =====================
panel_menu(){
    while true; do 
        banner
        echo -e "${WHITE}   [ ${CYAN}PANEL INSTALLATION MENU${WHITE} ]${NC}"
        separator
        echo -e "${PURPLE}   [01] ${WHITE}FeatherPanel"
        echo -e "${PURPLE}   [02] ${WHITE}Pterodactyl Panel"
        echo -e "${PURPLE}   [03] ${WHITE}Jexactyl Panel"
        echo -e "${PURPLE}   [04] ${WHITE}Skyport Panel (New)"
        echo -e "${PURPLE}   [05] ${WHITE}Mythical Dashboard"
        echo -e "${PURPLE}   [06] ${WHITE}Pelican Panel (Next-Gen)"
        echo -e "${PURPLE}   [07] ${WHITE}CPanel (CyberPanel)"
        separator
        echo -e "${RED}   [00] ${WHITE}Back to Main Menu"
        echo -e ""
        read -p "   Select Option → " p

        case $p in
            1|01) curl -sSL https://get.featherpanel.com/beta.sh | bash ;;
            2|02) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/Uninstall/unPterodactyl.sh) ;;
            3|03) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/panel/Jexactyl.sh) ;;
            4|04) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/panel/skyport.sh) ;;
            5|05) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/panel/MythicalDash.sh) ;;
            6|06) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/panel/pelican.sh) ;;
            7|07) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/panel/cpanel.sh) ;;
            0|00) break;;
            *) echo -e "${RED}   Invalid Option${NC}"; pause;;
        esac
    done
}
