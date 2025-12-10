#!/bin/bash
# ==========================================
# PTERODACTYL PANEL MANAGER
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

print_status() {
    local type=$1
    local message=$2
    case $type in
        "INFO")    echo -e "   ${BLUE}[INFO]${NC}    $message" ;;
        "WARN")    echo -e "   ${YELLOW}[WARN]${NC}    $message" ;;
        "ERROR")   echo -e "   ${RED}[ERROR]${NC}   $message" ;;
        "SUCCESS") echo -e "   ${GREEN}[SUCCESS]${NC} $message" ;;
        "INPUT")   echo -ne "   ${CYAN}[INPUT]${NC}   $message" ;;
    esac
}

# ===================== BANNER =====================
banner(){
    clear
    echo -e "${CYAN}"
    echo -e "   ██████╗ ████████╗███████╗██████╗  ██████╗ "
    echo -e "   ██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██╔═══██╗"
    echo -e "   ██████╔╝   ██║   █████╗  ██████╔╝██║   ██║"
    echo -e "   ██╔═══╝    ██║   ██╔══╝  ██╔══██╗██║   ██║"
    echo -e "   ██║        ██║   ███████╗██║  ██║╚██████╔╝"
    echo -e "   ╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝ "
    echo -e "${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# ===================== FUNCTIONS =====================

install_panel() {
    banner
    echo -e "${WHITE}   [ ${CYAN}INSTALL PTERODACTYL PANEL${WHITE} ]${NC}"
    separator
    echo -e "${GRAY}   This will run the official installation script.${NC}"
    echo -e ""
    print_status "INFO" "Starting Installer..."
    sleep 2
    
    # Run the external script as requested
    bash <(curl -s https://raw.githubusercontent.com/InfiniteandRaju/code/refs/heads/main/panel/Pterodactyl.sh)

    echo -e ""
    print_status "SUCCESS" "Installation sequence finished."
    pause
}

update_panel() {
    banner
    echo -e "${WHITE}   [ ${YELLOW}UPDATE PTERODACTYL PANEL${WHITE} ]${NC}"
    separator

    if [ ! -d "/var/www/pterodactyl" ]; then
        print_status "ERROR" "Panel directory not found (/var/www/pterodactyl)."
        pause; return
    fi

    echo -e "${YELLOW}   This will update the panel to the latest version.${NC}"
    print_status "INPUT" "Proceed? (y/N): "
    read CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then return; fi

    echo -e ""
    cd /var/www/pterodactyl || return

    print_status "INFO" " enabling Maintenance Mode..."
    php artisan down

    print_status "INFO" "Downloading latest release..."
    curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv

    print_status "INFO" "Setting permissions..."
    chmod -R 755 storage/* bootstrap/cache

    print_status "INFO" "Running Composer (Dependencies)..."
    composer install --no-dev --optimize-autoloader --quiet

    print_status "INFO" "Clearing Cache & Configs..."
    php artisan view:clear
    php artisan config:clear

    print_status "INFO" "Migrating Database..."
    php artisan migrate --seed --force

    print_status "INFO" "Setting Ownership..."
    chown -R www-data:www-data /var/www/pterodactyl/*

    print_status "INFO" "Restarting Queue Worker..."
    php artisan queue:restart

    print_status "INFO" "Disabling Maintenance Mode..."
    php artisan up

    echo -e ""
    print_status "SUCCESS" "Panel Updated Successfully!"
    pause
}

uninstall_panel() {
    banner
    echo -e "${WHITE}   [ ${RED}UNINSTALL PTERODACTYL PANEL${WHITE} ]${NC}"
    separator
    echo -e "${YELLOW}   ⚠️  WARNING: This will delete the Panel, Nginx configs, and Database!${NC}"
    echo -e "${YELLOW}   It does NOT remove Wings/Nodes.${NC}"
    echo -e ""
    
    print_status "INPUT" "Type 'DELETE' to confirm destruction: "
    read CONFIRM
    if [[ "$CONFIRM" != "DELETE" ]]; then
        print_status "INFO" "Aborted."
        pause; return
    fi

    echo -e ""
    print_status "INFO" "Stopping Services..."
    systemctl stop pteroq.service 2>/dev/null
    systemctl disable pteroq.service 2>/dev/null
    rm -f /etc/systemd/system/pteroq.service
    systemctl daemon-reload

    print_status "INFO" "Removing Cronjobs..."
    crontab -l | grep -v 'php /var/www/pterodactyl/artisan schedule:run' | crontab - 2>/dev/null

    print_status "INFO" "Deleting Files..."
    rm -rf /var/www/pterodactyl

    print_status "INFO" "Dropping Database & User..."
    mysql -u root -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null
    mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null
    mysql -u root -e "FLUSH PRIVILEGES;" 2>/dev/null

    print_status "INFO" "Cleaning Nginx..."
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    systemctl reload nginx 2>/dev/null

    echo -e ""
    print_status "SUCCESS" "Panel Uninstalled Successfully."
    pause
}

# ===================== MAIN MENU =====================
while true; do
    banner
    echo -e "${WHITE}   [ ${BLUE}PTERODACTYL MANAGER${WHITE} ]${NC}"
    separator
    echo -e "${PURPLE}   [01] ${WHITE}Install Panel"
    echo -e "${PURPLE}   [02] ${WHITE}Update Panel"
    echo -e "${PURPLE}   [03] ${WHITE}Uninstall Panel"
    separator
    echo -e "${RED}   [00] ${WHITE}Back / Exit"
    echo -e ""
    read -p "   Select Option → " opt

    case $opt in
        1|01) install_panel ;;
        2|02) update_panel ;;
        3|03) uninstall_panel ;;
        0|00) exit 0 ;;
        *) echo -e "${RED}   Invalid Option${NC}"; sleep 1 ;;
    esac
done
