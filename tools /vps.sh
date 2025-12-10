#!/bin/bash
# ==========================================
# VPS / VM MANAGER (Docker & IDX)
# Made By: Infinite21 & Staxxy Rai
# ==========================================

# --- COLORS & STYLING ---
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; 
BLUE='\033[1;34m'; PURPLE='\033[1;35m'; WHITE='\033[1;37m'; GRAY='\033[1;30m'; NC='\033[0m'

banner(){
    clear
    echo -e "${CYAN}"
    echo -e "   ██╗   ██╗██████╗ ███████╗    ███╗   ███╗ ██████╗██████╗ "
    echo -e "   ██║   ██║██╔══██╗██╔════╝    ████╗ ████║██╔════╝██╔══██╗"
    echo -e "   ██║   ██║██████╔╝███████╗    ██╔████╔██║██║     ██████╔╝"
    echo -e "   ╚██╗ ██╔╝██╔═══╝ ╚════██║    ██║╚██╔╝██║██║     ██╔══██╗"
    echo -e "    ╚████╔╝ ██║     ███████║    ██║ ╚═╝ ██║╚██████╗██║  ██║"
    echo -e "     ╚═══╝  ╚═╝     ╚══════╝    ╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${PURPLE}   ╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}   ║${WHITE}   Made By : ${CYAN}Infinite21 ${WHITE}& ${GREEN}Staxxy Rai   ${PURPLE}║${NC}"
    echo -e "${PURPLE}   ╚════════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# ===================== FUNCTIONS =====================

# --- OPTION 1: VM LAUNCHER (DOCKER) ---
run_vm_docker() {
    clear
    echo -e "${WHITE}   [ ${YELLOW}DOCKER VM LAUNCHER${WHITE} ]${NC}"
    separator
    
    # Config
    RAM=30000
    CPU=7
    DISK_SIZE=100G
    CONTAINER_NAME=rai
    IMAGE_NAME=rai/debain12
    VMDATA_DIR="$PWD/vmdata"

    # Check for Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}   Docker is not installed!${NC}"
        echo -e "${YELLOW}   Please install Docker first or run the 'System Tools' menu.${NC}"
        pause
        return
    fi

    echo -e "${CYAN}   1. Configuring Directory...${NC}"
    mkdir -p "$VMDATA_DIR"
    echo -e "      → Created $VMDATA_DIR"

    echo -e "${CYAN}   2. VM Configuration Set:${NC}"
    echo -e "      ${PURPLE}RAM:${WHITE}  $RAM MB"
    echo -e "      ${PURPLE}CPU:${WHITE}  $CPU Cores"
    echo -e "      ${PURPLE}DISK:${WHITE} $DISK_SIZE"
    echo -e "      ${PURPLE}IMG:${WHITE}  $IMAGE_NAME"

    echo -e "${CYAN}   3. Launching Container...${NC}"
    echo -e ""
    docker run -it --rm \
      --name "$CONTAINER_NAME" \
      --device /dev/kvm \
      -v "$VMDATA_DIR":/vmdata \
      -e RAM="$RAM" \
      -e CPU="$CPU" \
      -e DISK_SIZE="$DISK_SIZE" \
      "$IMAGE_NAME"

    echo -e ""
    echo -e "${GREEN}   VM Session Ended.${NC}"
    pause
}

# --- OPTION 2: IDX TOOL ---
setup_idx() {
    clear
    echo -e "${WHITE}   [ ${YELLOW}IDX TOOL SETUP${WHITE} ]${NC}"
    separator
    
    echo -e "${CYAN}   1. Cleaning environment...${NC}"
    cd ~ || exit
    rm -rf myapp flutter
    echo -e "      → Removed old folders."

    # Ensure vm directory exists
    if [ ! -d "vm" ]; then
        mkdir -p vm
        echo -e "      → Created ~/vm directory."
    fi
    cd vm || exit

    echo -e "${CYAN}   2. Configuring .idx...${NC}"
    if [ ! -d ".idx" ]; then
        mkdir .idx
        cd .idx || exit

        cat <<EOF > dev.nix
{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = with pkgs; [
    unzip
    openssh
    git
    qemu_kvm
    sudo
    cdrkit
    cloud-utils
    qemu
  ];

  env = {
    EDITOR = "nano";
  };

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    workspace = {
      onCreate = { };
      onStart = { };
    };

    previews = {
      enable = false;
    };
  };
}
EOF
        echo -e "${GREEN}      → dev.nix configuration created successfully.${NC}"
        echo -e "${WHITE}      Location: ~/vm/.idx/dev.nix${NC}"
    else
        echo -e "${YELLOW}      → .idx directory already exists. Skipping.${NC}"
    fi

    pause
}

# --- OPTION 3: EXTERNAL SCRIPT ---
run_external_script() {
    clear
    echo -e "${WHITE}   [ ${BLUE}RUNNING REMOTE VM SCRIPT${WHITE} ]${NC}"
    separator
    echo -e "${GRAY}   Credits: HopingBoyz(Best Youtuber)${NC}"
    echo -e "${YELLOW}   Initializing...${NC}"
    sleep 1
    echo -e ""
    
    bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/vms/main/vm.sh)
    
    echo -e ""
    pause
}

# ===================== MAIN MENU =====================
while true; do
    banner
    echo -e "${WHITE}   [ ${GREEN}DEVELOPMENT / VM MENU${WHITE} ]${NC}"
    separator
    echo -e "${PURPLE}   [01] ${WHITE}GitHub / Docker VM Launcher"
    echo -e "${PURPLE}   [02] ${WHITE}IDX Tool Configuration"
    echo -e "${PURPLE}   [03] ${WHITE}Run VM Script (External)"
    separator
    echo -e "${RED}   [00] ${WHITE}Back / Exit"
    echo -e ""
    read -p "   Select Option → " op

    case $op in
        1|01) run_vm_docker ;;
        2|02) setup_idx ;;
        3|03) run_external_script ;;
        0|00) 
            echo -e "${GREEN}   Exiting VM Manager.${NC}"
            exit 0 
            ;;
        *) 
            echo -e "${RED}   Invalid Option${NC}"; sleep 1 ;;
    esac
done
