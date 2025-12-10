#!/bin/bash
# ==========================================
# PTERODACTYL THEME MANAGER (Blueprint)
# Made By: Infinite21 & Staxxy Rai
# ==========================================

# --- COLORS & STYLING ---
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; 
BLUE='\033[1;34m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; GRAY='\033[1;30m'; NC='\033[0m'

# --- UTILS ---
separator(){
    echo -e "${BLUE}   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

pause(){
    echo -e ""
    echo -e "${GRAY}   [${WHITE}Press Enter to return...${GRAY}]${NC}"
    read -p "" x
}

check_dir(){
    if [ ! -d "/var/www/pterodactyl" ]; then
        echo -e "${RED}   [ERROR] Pterodactyl directory not found!${NC}"
        echo -e "${YELLOW}   Are you running this on the correct server?${NC}"
        pause
        return 1
    fi
    cd /var/www/pterodactyl || return 1
    return 0
}

# ===================== BANNER =====================
banner(){
    clear
    echo -e "${CYAN}"
    echo -e "   ██████╗ ██╗     ██╗   ██╗███████╗██████╗ ██████╗ ██╗███╗   ██╗████████╗"
    echo -e "   ██╔══██╗██║     ██║   ██║██╔════╝██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝"
    echo -e "   ██████╔╝██║     ██║   ██║█████╗  ██████╔╝██████╔╝██║██╔██╗ ██║   ██║   "
    echo -e "   ██╔══██╗██║     ██║   ██║██╔══╝  ██╔═══╝ ██╔══██╗██║██║╚██╗██║   ██║   "
    echo -e "   ██████╔╝███████╗╚██████╔╝███████╗██║     ██║  ██║██║██║ ╚████║   ██║   "
    echo -e "   ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# ===================== UNINSTALL MENU =====================
uninstall_menu() {
    while true; do
        banner
        echo -e "${WHITE}   [ ${RED}UNINSTALL MENU${WHITE} ]${NC}"
        separator
        echo -e "${PURPLE}   [01] ${WHITE}Remove Nebula Theme"
        echo -e "${PURPLE}   [02] ${WHITE}Remove Euphoria Theme"
        echo -e "${PURPLE}   [03] ${WHITE}Remove Tool Package (Plugins/Mgr)"
        separator
        echo -e "${RED}   [00] ${WHITE}Back to Theme Menu"
        echo -e ""
        read -p "   Select Option → " uopt

        case "$uopt" in
            1|01)
                check_dir || continue
                echo -e "${CYAN}   Removing Nebula...${NC}"
                blueprint -r nebula
                echo -e "${GREEN}   ✨ Nebula removed successfully!${NC}"
                pause
            ;;
            2|02)
                check_dir || continue
                echo -e "${CYAN}   Removing Euphoria...${NC}"
                blueprint -r euphoriatheme
                echo -e "${GREEN}   ✨ Euphoria removed successfully!${NC}"
                pause
            ;;
            3|03)
                check_dir || continue
                echo -e "${CYAN}   Removing Tools (Version/Plugins/PlayerMgr)...${NC}"
                blueprint -r versionchanger
                blueprint -r mcplugins
                blueprint -r sagaminecraftplayermanager
                echo -e "${GREEN}   ✨ Tool package removed!${NC}"
                pause
            ;;
            0|00) break ;;
            *) echo -e "${RED}   Invalid Option${NC}"; sleep 1 ;;
        esac
    done
}

# ===================== INSTALL FUNCTIONS =====================

install_nebula(){
    check_dir || return
    banner
    echo -e "${WHITE}   [ ${CYAN}NEBULA AUTO-INSTALLER${WHITE} ]${NC}"
    separator
    
    echo -e "${YELLOW}   Downloading Nebula Blueprint...${NC}"
    wget -q https://github.com/InfiniteandRaju/thm/raw/refs/heads/main/sc/nebula.blueprint
    
    echo -e "${YELLOW}   Installing (Auto-Confirming)...${NC}"
    # Auto-enter 'yes' for blueprint prompts
    yes "" | blueprint -i nebula
    
    rm -f nebula.blueprint
    echo -e "${GREEN}   🚀 Nebula Theme Installed!${NC}"
    pause
}

install_euphoria(){
    check_dir || return
    banner
    echo -e "${WHITE}   [ ${CYAN}EUPHORIA INSTALLER${WHITE} ]${NC}"
    separator
    
    echo -e "${YELLOW}   Downloading Euphoria Blueprint...${NC}"
    wget -q https://github.com/InfiniteandRaju/thm/raw/refs/heads/main/sc/euphoriatheme.blueprint
    
    echo -e "${YELLOW}   Installing...${NC}"
    blueprint -i euphoriatheme
    
    rm -f euphoriatheme.blueprint
    echo -e "${GREEN}   🌟 Euphoria Theme Installed!${NC}"
    pause
}

install_tools(){
    check_dir || return
    banner
    echo -e "${WHITE}   [ ${CYAN}ADDON TOOLS INSTALLER${WHITE} ]${NC}"
    separator
    echo -e "${GRAY}   Installing: VersionChanger, MCPlugins, PlayerManager${NC}"
    echo -e ""

    echo -e "${YELLOW}   1/3 Downloading assets...${NC}"
    wget -q https://github.com/InfiniteandRaju/thm/raw/refs/heads/main/sc/versionchanger.blueprint
    wget -q https://github.com/InfiniteandRaju/thm/raw/refs/heads/main/sc/mcplugins.blueprint
    wget -q https://github.com/InfiniteandRaju/thm/raw/refs/heads/main/sc/sagaminecraftplayermanager.blueprint

    echo -e "${YELLOW}   2/3 Installing Blueprints...${NC}"
    blueprint -i versionchanger
    blueprint -i mcplugins
    blueprint -i sagaminecraftplayermanager

    echo -e "${YELLOW}   3/3 Cleaning up...${NC}"
    rm -f versionchanger.blueprint mcplugins.blueprint sagaminecraftplayermanager.blueprint

    echo -e "${GREEN}   🧩 All Tools Installed Successfully!${NC}"
    pause
}

# ===================== MAIN MENU =====================
while true; do
    banner
    echo -e "${WHITE}   [ ${BLUE}THEME & BLUEPRINT MENU${WHITE} ]${NC}"
    separator
    echo -e "${PURPLE}   [01] ${WHITE}Nebula Theme ${GRAY}(Auto Install)"
    echo -e "${PURPLE}   [02] ${WHITE}Euphoria Theme ${GRAY}(Standard)"
    echo -e "${PURPLE}   [03] ${WHITE}Addon Tools ${GRAY}(Version/Plugins/Mgr)"
    echo -e "${PURPLE}   [04] ${WHITE}Uninstall Menu"
    separator
    echo -e "${RED}   [00] ${WHITE}Exit"
    echo -e ""
    read -p "   Select Option → " opt

    case "$opt" in
        1|01) install_nebula ;;
        2|02) install_euphoria ;;
        3|03) install_tools ;;
        4|04) uninstall_menu ;;
        0|00) 
            echo -e "${CYAN}   Goodbye, legend… 🚀${NC}"
            exit 0 
            ;;
        *) echo -e "${RED}   Invalid Option${NC}"; sleep 1 ;;
    esac
done
