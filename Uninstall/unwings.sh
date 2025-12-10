#!/bin/bash
# ==========================================
# PTERODACTYL WINGS MANAGER
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
    echo -e "   ██╗    ██╗██╗███╗   ██╗ ██████╗ ██████╗ "
    echo -e "   ██║    ██║██║████╗  ██║██╔════╝██╔════╝ "
    echo -e "   ██║ █╗ ██║██║██╔██╗ ██║██║  ███╗███████╗"
    echo -e "   ██║███╗██║██║██║╚██╗██║██║   ██║╚════██║"
    echo -e "   ╚███╔███╔╝██║██║ ╚████║╚██████╔╝███████║"
    echo -e "    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# ===================== FUNCTIONS =====================

install_wings_public() {
    banner
    echo -e "${WHITE}   [ ${CYAN}PUBLIC IP & WINGS SETUP${WHITE} ]${NC}"
    separator

    # 1. IP Check
    print_status "INFO" "Detecting Public IP..."
    PUBLIC_IP=$(curl -s https://ipinfo.io/ip || echo "Unknown")
    echo -e "   → Public IP: ${WHITE}$PUBLIC_IP${NC}"
    echo -e ""

    # 2. Domain Input
    print_status "INPUT" "Enter Domain for SSL (e.g., node1.example.com): "
    read DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        print_status "ERROR" "No domain entered. Aborting."
        pause; return
    fi
    echo -e "   → Using Domain: ${WHITE}$DOMAIN${NC}"
    echo -e ""

    # 3. Dependencies
    print_status "INFO" "Updating system & installing dependencies..."
    apt update -y -q > /dev/null 2>&1
    apt install -y mysql-server mariadb-server certbot python3-certbot-nginx -q > /dev/null 2>&1
    
    systemctl enable --now mysql > /dev/null 2>&1
    systemctl enable --now mariadb > /dev/null 2>&1

    # 4. SSL
    print_status "INFO" "Requesting SSL Certificate..."
    certbot certonly --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN" > /dev/null 2>&1
    
    # 5. Database Setup
    echo -e ""
    separator
    echo -e "${WHITE}   [ ${YELLOW}DATABASE CONFIGURATION${WHITE} ]${NC}"
    
    print_status "INPUT" "Database Name [root]: "; read DB_NAME
    DB_NAME=${DB_NAME:-root}
    
    print_status "INPUT" "Database User [root]: "; read DB_USER
    DB_USER=${DB_USER:-root}
    
    print_status "INPUT" "Database Pass [root]: "; read DB_PASS
    DB_PASS=${DB_PASS:-root}
    
    print_status "INFO" "Configuring MariaDB..."
    mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';" > /dev/null 2>&1
    mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" > /dev/null 2>&1
    mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;" > /dev/null 2>&1
    mariadb -e "FLUSH PRIVILEGES;" > /dev/null 2>&1

    # Bind Address Fix
    CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
    if [ -f "$CONF_FILE" ]; then
        sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$CONF_FILE"
    fi
    systemctl restart mariadb

    # 6. Docker & Wings
    echo -e ""
    separator
    echo -e "${WHITE}   [ ${BLUE}DOCKER & WINGS${WHITE} ]${NC}"
    
    print_status "INFO" "Installing Docker..."
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash > /dev/null 2>&1
    systemctl enable --now docker > /dev/null 2>&1

    print_status "INFO" "Updating GRUB (Swap Support)..."
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"/' /etc/default/grub
    update-grub > /dev/null 2>&1

    print_status "INFO" "Downloading Wings..."
    mkdir -p /etc/pterodactyl
    ARCH=$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")
    curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$ARCH" > /dev/null 2>&1
    chmod u+x /usr/local/bin/wings

    # Service File
    cat <<EOF > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
[Service]
User=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/usr/local/bin/wings
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable wings > /dev/null 2>&1

    echo -e ""
    print_status "SUCCESS" "Installation Complete!"
    echo -e "${PURPLE}   Please paste your Node Configuration token from the Panel.${NC}"
    echo -e "${PURPLE}   Then run: ${WHITE}systemctl start wings${NC}"
    pause
}

check_local_ip() {
    banner
    echo -e "${WHITE}   [ ${CYAN}LOCAL NETWORK INFO${WHITE} ]${NC}"
    separator
    echo -e "${GRAY}   Fetching local details via external script...${NC}"
    echo -e ""
    # Retaining original functionality link
    bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/panel/wing.sh)
    echo -e ""
    pause
}

uninstall_wings() {
    banner
    echo -e "${WHITE}   [ ${RED}UNINSTALL WINGS${WHITE} ]${NC}"
    separator
    echo -e "${YELLOW}   This will remove Wings, Docker images, and configs.${NC}"
    echo -e "${YELLOW}   Your Panel files will NOT be touched.${NC}"
    echo -e ""
    
    print_status "INPUT" "Are you sure? (y/N): "; read CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        print_status "INFO" "Cancelled."
        pause; return
    fi

    print_status "INFO" "Stopping Services..."
    systemctl disable --now wings 2>/dev/null
    rm -f /etc/systemd/system/wings.service
    rm -rf /etc/pterodactyl /var/lib/pterodactyl /usr/local/bin/wings
    
    print_status "INFO" "Pruning Docker..."
    docker system prune -a -f 2>/dev/null

    echo -e ""
    print_status "INPUT" "Remove MariaDB Database? (y/N): "; read DBDEL
    if [[ "$DBDEL" == "y" || "$DBDEL" == "Y" ]]; then
        print_status "INPUT" "DB Name to delete: "; read DROPDB
        print_status "INPUT" "DB User to delete: "; read DROPUSER
        
        [[ -n "$DROPDB" ]] && mariadb -e "DROP DATABASE IF EXISTS $DROPDB;" 2>/dev/null
        [[ -n "$DROPUSER" ]] && mariadb -e "DROP USER IF EXISTS '$DROPUSER'@'127.0.0.1';" 2>/dev/null
        mariadb -e "FLUSH PRIVILEGES;" 2>/dev/null
        print_status "SUCCESS" "Database cleared."
    fi

    print_status "SUCCESS" "Uninstallation Complete."
    pause
}

# ===================== MAIN MENU =====================
while true; do
    banner
    echo -e "${WHITE}   [ ${BLUE}WINGS MANAGER MENU${WHITE} ]${NC}"
    separator
    echo -e "${PURPLE}   [01] ${WHITE}Install Wings ${GRAY}(Public IP/SSL/DB)"
    echo -e "${PURPLE}   [02] ${WHITE}Check Local IP ${GRAY}(For Nat/Home)"
    echo -e "${PURPLE}   [03] ${WHITE}Uninstall Wings"
    separator
    echo -e "${RED}   [00] ${WHITE}Back / Exit"
    echo -e ""
    read -p "   Select Option → " opt

    case $opt in
        1|01) install_wings_public ;;
        2|02) check_local_ip ;;
        3|03) uninstall_wings ;;
        0|00) exit 0 ;;
        *) echo -e "${RED}   Invalid Option${NC}"; sleep 1 ;;
    esac
done
