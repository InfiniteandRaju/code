#!/bin/bash
# ==========================================
# RDP / GUI INSTALLER (XRDP + XFCE)
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
    echo -e "   ██████╗ ██████╗ ██████╗     ██████╗ ██╗   ██╗██╗"
    echo -e "   ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██║"
    echo -e "   ██████╔╝██║  ██║██████╔╝    ██║  ███╗██║   ██║██║"
    echo -e "   ██╔══██╗██║  ██║██╔═══╝     ██║   ██║██║   ██║██║"
    echo -e "   ██║  ██║██████╔╝██║         ╚██████╔╝╚██████╔╝██║"
    echo -e "   ╚═╝  ╚═╝╚═════╝ ╚═╝          ╚═════╝  ╚═════╝ ╚═╝"
    echo -e "${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# ===================== FUNCTIONS =====================

install_rdp() {
    banner
    echo -e "${WHITE}   [ ${CYAN}INSTALL DESKTOP ENVIRONMENT${WHITE} ]${NC}"
    separator
    echo -e "${GRAY}   This will install XFCE4 (Lightweight GUI) and XRDP.${NC}"
    echo -e ""

    print_status "INFO" "Updating package lists..."
    sudo apt-get update -y -q > /dev/null 2>&1

    print_status "INFO" "Installing XFCE4 Desktop (This may take time)..."
    # Suppress output but show it's working
    sudo apt-get install -y xfce4 xfce4-goodies -q > /dev/null 2>&1

    print_status "INFO" "Installing XRDP Server..."
    sudo apt-get install -y xrdp -q > /dev/null 2>&1

    print_status "INFO" "Installing Browser (Firefox)..."
    sudo apt-get install -y firefox -q > /dev/null 2>&1

    print_status "INFO" "Configuring Session..."
    echo "xfce4-session" > ~/.xsession
    
    # Permission fixes for RDP
    if [ -f /etc/xrdp/xrdp.ini ]; then
        sudo sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini
        sudo sed -i 's/max_bpp=32/max_bpp=128000/g' /etc/xrdp/xrdp.ini
        sudo sed -i 's/xserverbpp=24/xserverbpp=128000/g' /etc/xrdp/xrdp.ini
    fi

    print_status "INFO" "Restarting Services..."
    sudo systemctl enable xrdp > /dev/null 2>&1
    sudo systemctl restart xrdp

    # Get IP
    IP=$(curl -s https://ipinfo.io/ip)
    USER=$(whoami)

    echo -e ""
    print_status "SUCCESS" "Installation Complete!"
    separator
    echo -e "${WHITE}   [ CONNECTION DETAILS ]${NC}"
    echo -e "   ${PURPLE}IP Address:${NC}  $IP"
    echo -e "   ${PURPLE}Port:${NC}        3389 (Default)"
    echo -e "   ${PURPLE}Username:${NC}    $USER"
    echo -e "   ${PURPLE}Password:${NC}    (Your VPS Password)"
    echo -e ""
    echo -e "${YELLOW}   Use 'Remote Desktop Connection' on Windows/Mac to connect.${NC}"
    pause
}

uninstall_rdp() {
    banner
    echo -e "${WHITE}   [ ${RED}UNINSTALL GUI & RDP${WHITE} ]${NC}"
    separator
    print_status "INPUT" "Are you sure you want to remove the desktop? (y/N): "
    read CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then return; fi
    
    echo -e ""
    print_status "INFO" "Removing XRDP..."
    sudo systemctl stop xrdp
    sudo apt-get remove --purge -y xrdp
    
    print_status "INFO" "Removing XFCE4..."
    sudo apt-get remove --purge -y xfce4 xfce4-goodies
    
    print_status "INFO" "Cleaning up packages..."
    sudo apt-get autoremove -y
    
    rm -f ~/.xsession
    
    echo -e ""
    print_status "SUCCESS" "Desktop Environment Removed."
    pause
}

create_user() {
    banner
    echo -e "${WHITE}   [ ${YELLOW}CREATE RDP USER${WHITE} ]${NC}"
    separator
    echo -e "${GRAY}   Create a specific user for Remote Desktop access.${NC}"
    echo -e ""
    
    print_status "INPUT" "Enter New Username: "
    read NEWUSER
    
    if id "$NEWUSER" &>/dev/null; then
        print_status "ERROR" "User $NEWUSER already exists."
        pause; return
    fi
    
    sudo adduser $NEWUSER
    sudo usermod -aG sudo $NEWUSER
    
    # Set xsession for new user
    sudo bash -c "echo xfce4-session > /home/$NEWUSER/.xsession"
    sudo chown $NEWUSER:$NEWUSER /home/$NEWUSER/.xsession
    
    echo -e ""
    print_status "SUCCESS" "User $NEWUSER created!"
    pause
}

# ===================== MAIN MENU =====================
while true; do
    banner
    echo -e "${WHITE}   [ ${BLUE}RDP MANAGER MENU${WHITE} ]${NC}"
    separator
    echo -e "${PURPLE}   [01] ${WHITE}Install GUI & RDP (XFCE)"
    echo -e "${PURPLE}   [02] ${WHITE}Create New RDP User"
    echo -e "${PURPLE}   [03] ${WHITE}Uninstall RDP"
    separator
    echo -e "${RED}   [00] ${WHITE}Back / Exit"
    echo -e ""
    read -p "   Select Option → " opt

    case $opt in
        1|01) install_rdp ;;
        2|02) create_user ;;
        3|03) uninstall_rdp ;;
        0|00) exit 0 ;;
        *) echo -e "${RED}   Invalid Option${NC}"; sleep 1 ;;
    esac
done
