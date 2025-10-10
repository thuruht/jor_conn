#!/bin/bash
# Jor-Conn - Shared Library
# Contains common functions and variables for all jor-conn scripts.

# --- Colors and Styles ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# --- ASCII Art Banner ---
show_banner() {
    echo -e "${PURPLE}"
    cat << 'ART'
    ██╗ ██████╗ ██████╗     ██████╗ ██████╗ ███╗   ██╗███╗   ██╗
    ██║██╔═══██╗██╔══██╗   ██╔════╝██╔═══██╗████╗  ██║████╗  ██║
    ██║██║   ██║██████╔╝   ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║
██╗ ██║██║   ██║██╔══██╗   ██║     ██║   ██║██║╚██╗██║██║╚██╗██║
╚█████╔╝╚██████╔╝██║  ██║   ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║
 ╚════╝  ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝
ART
    echo -e "${NC}"
}

# --- UI Functions ---
progress_bar() {
    local duration=${1:-2}
    local message=${2:-"Processing..."}
    local steps=20
    local step_delay=$(echo "scale=3; $duration/$steps" | bc -l 2>/dev/null || echo "0.1")

    echo -n "${message} "
    local bar=""
    for ((i=0; i<steps; i++)); do
        bar+="█"
        echo -ne "\r${message} [${bar}]"
        sleep $step_delay 2>/dev/null || sleep 0.1
    done
    echo -e " ${GREEN}✓${NC}"
}

# --- Logging Function ---
log() {
    # Ensure log directory and file exist and are writable
    if [ ! -d "/var/log/jor-conn" ]; then
        mkdir -p /var/log/jor-conn &>/dev/null
    fi
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE" &>/dev/null
    fi
    if [ ! -w "$LOG_FILE" ]; then
        chmod 666 "$LOG_FILE" &>/dev/null
        if [ ! -w "$LOG_FILE" ]; then
            return # Cannot write to log, so exit function
        fi
    fi
    echo "$(date): $1" >> "$LOG_FILE"
}