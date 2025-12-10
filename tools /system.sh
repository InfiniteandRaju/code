#!/bin/bash
# ==========================================
# VPS SYSTEM ANALYZER PRO
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
    echo -e "   ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗"
    echo -e "   ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║"
    echo -e "   ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║"
    echo -e "   ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║"
    echo -e "   ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║"
    echo -e "   ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝"
    echo -e "${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# ===================== MODULES =====================

# --- 1. SYSTEM INFO ---
sys_info() {
    banner
    echo -e "${WHITE}   [ ${CYAN}SYSTEM INFORMATION${WHITE} ]${NC}"
    separator
    hostnamectl | sed 's/^/   /'
    echo -e ""
    echo -e "   ${PURPLE}Kernel:${NC} $(uname -r)"
    echo -e "   ${PURPLE}Uptime:${NC} $(uptime -p)"
    pause
}

# --- 2. DISK & RAM ---
disk_ram() {
    banner
    echo -e "${WHITE}   [ ${YELLOW}MEMORY & STORAGE${WHITE} ]${NC}"
    separator
    echo -e "${CYAN}   RAM Usage:${NC}"
    free -h | sed 's/^/   /'
    echo -e ""
    echo -e "${CYAN}   Disk Usage:${NC}"
    df -h | grep '^/dev/' | sed 's/^/   /'
    pause
}

# --- 3. NETWORK INFO ---
net_info() {
    banner
    echo -e "${WHITE}   [ ${BLUE}NETWORK INTERFACES${WHITE} ]${NC}"
    separator
    ip a | grep 'inet ' | awk '{print "   " $2}'
    echo -e ""
    echo -e "${CYAN}   Public IP:${NC} $(curl -s https://ipinfo.io/ip || echo 'Unknown')"
    pause
}

# --- 4. FAKE VPS CHECK ---
fake_check() {
    banner
    echo -e "${WHITE}   [ ${RED}REALITY CHECK (FAKE VPS)${WHITE} ]${NC}"
    separator
    
    echo -e "   ${YELLOW}Virtualization Technology:${NC}"
    VIRT=$(systemd-detect-virt)
    echo -e "   → $VIRT"
    echo -e ""
    
    echo -e "   ${YELLOW}Checking CPU Flags (VMX/SVM):${NC}"
    if grep -E -o "vmx|svm" /proc/cpuinfo >/dev/null; then
        print_status "SUCCESS" "Hardware virtualization flags present."
        echo -e "   ${GREEN}   (Likely a KVM/Dedicated or nested virt enabled)${NC}"
    else
        print_status "ERROR" "VMX/SVM Flags NOT found."
        echo -e "   ${RED}   (Likely OpenVZ, LXC, or a weak/oversold VPS)${NC}"
    fi
    pause
}

# --- 5. LIVE TRAFFIC ---
live_traffic() {
    banner
    echo -e "${WHITE}   [ ${CYAN}LIVE TRAFFIC MONITOR${WHITE} ]${NC}"
    separator
    
    if ! command -v iftop >/dev/null 2>&1; then
        print_status "WARN" "iftop not found. Installing..."
        sudo apt-get update -q && sudo apt-get install -y iftop -q
    fi
    
    echo -e "${YELLOW}   Loading Traffic Monitor...${NC}"
    echo -e "${GRAY}   (Press 'q' or 'Ctrl+C' to exit monitor)${NC}"
    sleep 2
    sudo iftop -n -P
    pause
}

# --- 6. BTOP MODE (DASHBOARD) ---
draw_bar() {
    local used=$1
    local total=$2
    (( total == 0 )) && total=1
    local p=$(( used * 100 / total ))
    local filled=$(( p / 2 ))
    local empty=$(( 50 - filled ))
    printf "${GREEN}%3s%% ${GRAY}[" "$p"
    printf "${CYAN}%0.s█" $(seq 1 $filled)
    printf "${GRAY}%0.s░" $(seq 1 $empty)
    printf "${GRAY}]${NC}"
}

btop_live() {
    # Install dependencies silently if missing
    if ! command -v mpstat >/dev/null 2>&1; then
        sudo apt-get install -y sysstat -q >/dev/null 2>&1
    fi

    while true; do
        clear
        echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}   ║${WHITE}             VPS LIVE MONITOR DASHBOARD                 ${PURPLE}║${NC}"
        echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
        echo -e ""

        # CPU
        if command -v mpstat >/dev/null 2>&1; then
            echo -e "   ${YELLOW}CPU Cores:${NC}"
            mpstat -P ALL 1 1 | awk '/Average/ && $2 ~ /[0-9]/ {printf "   Core %-2s : %3s%%\n",$2,100-$12}'
        else
            echo -e "   ${RED}   (sysstat not installed for CPU breakdown)${NC}"
        fi

        # RAM
        mem_used=$(free -m | awk '/Mem/ {print $3}')
        mem_total=$(free -m | awk '/Mem/ {print $2}')
        echo -e "\n   ${YELLOW}RAM Usage:${NC}"
        printf "   "
        draw_bar "$mem_used" "$mem_total"
        echo -e " ${WHITE}${mem_used}MB / ${mem_total}MB${NC}"

        # DISK
        disk_used=$(df / | awk 'NR==2 {print $3}')
        disk_total=$(df / | awk 'NR==2 {print $2}')
        # Convert blocks to roughly MB for bar calc logic if needed, or just raw blocks
        # Simply use % from df for bar
        d_p=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
        disk_used_mb=$((disk_used / 1024))
        disk_total_mb=$((disk_total / 1024))
        
        echo -e "\n   ${YELLOW}Disk (Root):${NC}"
        printf "   "
        draw_bar "$disk_used" "$disk_total"
        echo -e " ${WHITE}${disk_used_mb}MB / ${disk_total_mb}MB${NC}"

        # TOP PROCESS
        echo -e "\n   ${BLUE}Top Processes (CPU):${NC}"
        ps -eo pid,cmd,%mem,%cpu --sort=-%cpu | head -6 | awk '{printf "   %-6s %-20s CPU: %s%%\n", $1, substr($2,1,20), $4}'

        # NETWORK
        rx1=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | paste -sd+)
        tx1=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | paste -sd+)
        sleep 1
        rx2=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | paste -sd+)
        tx2=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | paste -sd+)
        rx_kb=$(( (rx2 - rx1) / 1024 ))
        tx_kb=$(( (tx2 - tx1) / 1024 ))
        
        echo -e "\n   ${GREEN}Network Speed:${NC} ⬇ ${rx_kb} KB/s   ⬆ ${tx_kb} KB/s"

        echo -e "\n   ${GRAY}Press CTRL+C to exit dashboard...${NC}"
    done
}

# --- 7. SPEEDTEST ---
speedtest_run() {
    banner
    echo -e "${WHITE}   [ ${YELLOW}SPEEDTEST CLI${WHITE} ]${NC}"
    separator
    if ! command -v speedtest-cli &>/dev/null; then
        print_status "WARN" "Installing speedtest-cli..."
        sudo apt-get update -y -q && sudo apt-get install -y speedtest-cli -q
    fi
    echo -e "${CYAN}   Running network test...${NC}"
    echo -e ""
    speedtest-cli --simple | sed 's/^/   /'
    pause
}

# --- 8. LOGS ---
logs_view() {
    banner
    echo -e "${WHITE}   [ ${BLUE}SYSTEM LOGS (Last 50)${WHITE} ]${NC}"
    separator
    journalctl -n 50 --no-pager | sed 's/^/   /'
    pause
}

# --- 9. TEMP MONITOR ---
temp_monitor() {
    banner
    echo -e "${WHITE}   [ ${RED}TEMPERATURE MONITOR${WHITE} ]${NC}"
    separator
    if ! command -v sensors &>/dev/null; then
        print_status "WARN" "Installing lm-sensors..."
        sudo apt-get update -y -q && sudo apt-get install -y lm-sensors -q
        sudo sensors-detect --auto
    fi
    echo -e "${CYAN}   Live View (Ctrl+C to exit)...${NC}"
    sleep 1
    watch -n 1 sensors
}

# --- 10. DDOS CHECK ---
ddos_check() {
    while true; do
        clear
        echo -e "${WHITE}   [ ${RED}DDoS / ABUSE MONITOR${WHITE} ]${NC}"
        separator
        echo -e "${CYAN}   Top IPs by Connections:${NC}"
        ss -tuna | awk 'NR>1{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head | sed 's/^/   /'
        echo -e ""
        echo -e "${YELLOW}   System Load:${NC} $(uptime | awk -F'load average:' '{print $2}')"
        echo -e "\n   ${GRAY}Refreshing every 2s... (Ctrl+C to exit)${NC}"
        sleep 2
    done
}

# ===================== MAIN MENU =====================
while true; do
    banner
    echo -e "${WHITE}   [ ${BLUE}SYSTEM ANALYZER MENU${WHITE} ]${NC}"
    separator
    echo -e "${PURPLE}   [01] ${WHITE}System Information"
    echo -e "${PURPLE}   [02] ${WHITE}Disk & RAM Usage"
    echo -e "${PURPLE}   [03] ${WHITE}Network Information"
    echo -e "${PURPLE}   [04] ${WHITE}Fake / Real VPS Check"
    echo -e "${PURPLE}   [05] ${WHITE}Live Traffic (iftop)"
    echo -e "${PURPLE}   [06] ${WHITE}BTOP Dashboard (Live)"
    echo -e "${PURPLE}   [07] ${WHITE}Internet Speedtest"
    echo -e "${PURPLE}   [08] ${WHITE}System Logs Viewer"
    echo -e "${PURPLE}   [09] ${WHITE}Temperature Monitor"
    echo -e "${PURPLE}   [10] ${WHITE}DDoS / Connection Check"
    separator
    echo -e "${RED}   [00] ${WHITE}Back / Exit"
    echo -e ""
    read -p "   Select Option → " opt

    case $opt in
        1|01) sys_info ;;
        2|02) disk_ram ;;
        3|03) net_info ;;
        4|04) fake_check ;;
        5|05) live_traffic ;;
        6|06) btop_live ;;
        7|07) speedtest_run ;;
        8|08) logs_view ;;
        9|09) temp_monitor ;;
        10) ddos_check ;;
        0|00) exit 0 ;;
        *) echo -e "${RED}   Invalid Option${NC}"; sleep 1 ;;
    esac
done
