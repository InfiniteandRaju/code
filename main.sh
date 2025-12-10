#!/bin/bash
# ===========================================================
# VAI NODES Terminal Control Panel
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
            0|00) return;; # Use Return to go back
            *) echo -e "${RED}   Invalid Option${NC}"; pause;;
        esac
    done
}

# ===================== TOOLS MENU =====================
tools_menu(){
    while true; do 
        banner
        echo -e "${WHITE}   [ ${BLUE}SYSTEM TOOLS MENU${WHITE} ]${NC}"
        separator
        echo -e "${PURPLE}   [01] ${WHITE}Root Access Configuration"
        echo -e "${PURPLE}   [02] ${WHITE}Install Tailscale"
        echo -e "${PURPLE}   [03] ${WHITE}Cloudflare DNS Setup"
        echo -e "${PURPLE}   [04] ${WHITE}System Information"
        echo -e "${PURPLE}   [05] ${WHITE}Port Forwarding"
        echo -e "${PURPLE}   [06] ${WHITE}RDP Installer"
        echo -e "${PURPLE}   [07] ${WHITE}Docker Manager"
        echo -e "${PURPLE}   [08] ${WHITE}Swap Memory Manager"
        echo -e "${PURPLE}   [09] ${WHITE}Software Installer (Java/Node)"
        separator
        echo -e "${RED}   [00] ${WHITE}Back to Main Menu"
        echo -e ""
        read -p "   Select Option → " t

        case $t in
            1|01) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/root.sh) ;;
            2|02) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/tailscale.sh) ;;
            3|03) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/cf.sh) ;;
            4|04) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/system.sh) ;;
            5|05) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/portforward.sh) ;;
            6|06) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/rdp.sh) ;;
            7|07) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/docker.sh) ;;
            8|08) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/swap.sh) ;;
            9|09) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/software.sh) ;;
            0|00) return;; # Use Return to go back
            *) echo -e "${RED}   Invalid Option${NC}"; pause;;
        esac
    done
}

# ===================== THEME MENU =====================
theme_menu(){
    while true; do 
        banner
        echo -e "${WHITE}   [ ${PURPLE}THEME MANAGER${WHITE} ]${NC}"
        separator
        echo -e "${PURPLE}   [01] ${WHITE}Install Blueprint Theme"
        echo -e "${PURPLE}   [02] ${WHITE}Change Panel Theme"
        echo -e "${PURPLE}   [03] ${WHITE}Uninstall Theme"
        separator
        echo -e "${RED}   [00] ${WHITE}Back to Main Menu"
        echo -e ""
        read -p "   Select Option → " th

        case $th in
            1|01) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/theme/blueprint.sh) ;;
            2|02) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/theme/change.sh) ;;
            3|03) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/theme/theme_uninstall.sh) ;;
            0|00) return;; # Use Return to go back
            *) echo -e "${RED}   Invalid Option${NC}"; pause;;
        esac
    done
}

# ===================== MAIN MENU =====================
main_menu(){
    while true; do 
        banner
        echo -e "${WHITE}   [ ${GREEN}MAIN MENU${WHITE} ]${NC}"
        separator
        echo -e "${PURPLE}   [01] ${WHITE}VPS Optimizer / Run"
        echo -e "${PURPLE}   [02] ${WHITE}Panel Installer"
        echo -e "${PURPLE}   [03] ${WHITE}Wings Installer/Manager"
        echo -e "${PURPLE}   [04] ${WHITE}System Tools"
        echo -e "${PURPLE}   [05] ${WHITE}Theme Manager"
        separator
        echo -e "${RED}   [00] ${WHITE}Exit Control Panel"
        echo -e ""
        read -p "   Select Option → " c

        case $c in
            1|01) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/tools/vps.sh) ;;
            2|02) panel_menu;;
            3|03) bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/Uninstall/unwings.sh) ;;
            4|04) tools_menu;;
            5|05) theme_menu;;
            0|00) 
                echo -e ""
                echo -e "${GREEN}   Thank you for using Vai Nodes Control Panel.${NC}"
                echo -e "${CYAN}   Credits: Infinite21 & Staxxy Rai${NC}"
                # Changed from break to exit 0 to fix the VS Code error
                exit 0
                ;;
            *) echo -e "${RED}   Invalid Option${NC}"; pause;;
        esac
    done
}

# ===================== EXECUTION START =====================
main_menu
