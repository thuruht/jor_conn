#!/bin/bash
# Jor Connector ULTIMATE Edition
# Complete package with all features: ASCII art, progress bars, Easter eggs, troubleshooting, and more!

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ASCII Art Gallery
show_banner() {
    echo -e "${PURPLE}"
    case $((RANDOM % 4)) in
        0)
           cat << 'ART'
    ██╗ ██████╗ ██████╗     ██████╗ ██████╗ ███╗   ██╗███╗   ██╗
    ██║██╔═══██╗██╔══██╗   ██╔════╝██╔═══██╗████╗  ██║████╗  ██║
    ██║██║   ██║██████╔╝   ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║
██╗ ██║██║   ██║██╔══██╗   ██║     ██║   ██║██║╚██╗██║██║╚██╗██║
╚█████╔╚██████╔╝██║  ██║   ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║
 ╚════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝
ART
    ;;
        1)
                       cat << 'ART'
    ██╗ ██████╗ ██████╗     ██████╗ ██████╗ ███╗   ██╗███╗   ██╗
    ██║██╔═══██╗██╔══██╗   ██╔════╝██╔═══██╗████╗  ██║████╗  ██║
    ██║██║   ██║██████╔╝   ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║
██╗ ██║██║   ██║██╔══██╗   ██║     ██║   ██║██║╚██╗██║██║╚██╗██║
╚█████╔╚██████╔╝██║  ██║   ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║
 ╚════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝
ART
    ;;
        2)
                     cat << 'ART'
    ██╗ ██████╗ ██████╗     ██████╗ ██████╗ ███╗   ██╗███╗   ██╗
    ██║██╔═══██╗██╔══██╗   ██╔════╝██╔═══██╗████╗  ██║████╗  ██║
    ██║██║   ██║██████╔╝   ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║
██╗ ██║██║   ██║██╔══██╗   ██║     ██║   ██║██║╚██╗██║██║╚██╗██║
╚█████╔╚██████╔╝██║  ██║   ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║
 ╚════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝
ART
    ;;
        3)
                      cat << 'ART'
    ██╗ ██████╗ ██████╗     ██████╗ ██████╗ ███╗   ██╗███╗   ██╗
    ██║██╔═══██╗██╔══██╗   ██╔════╝██╔═══██╗████╗  ██║████╗  ██║
    ██║██║   ██║██████╔╝   ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║
██╗ ██║██║   ██║██╔══██╗   ██║     ██║   ██║██║╚██╗██║██║╚██╗██║
╚█████╔╚██████╔╝██║  ██║   ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║
 ╚════╝ ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝
ART
    ;;
    esac
    echo -e "${NC}"
}

# Easter Egg Messages
EasterEggs=(
    "🌟 Jor's Legendary Connection Adventure!"
    "🚀 Turbo mode engaged! Za Warudo!"
    "💎 Diamond is Unbreakable connection!"
    "⚡ Golden Wind of data flowing!"
    "🎯 Crazy Diamond reliable connection!"
    "🌙 Stardust Crusaders network journey!"
    "🔥 Burning Down the House with speed!"
    "🌀 Made in Heaven fast connection!"
    "🎨 Greatful Dead slow connection revived!"
    "🌊 Stone Ocean smooth streaming!"
)

# Progress bars with different styles
progress_bar() {
    local duration=${1:-2}
    local style=${2:-1}
    local message=${3:-"Processing..."}
    local steps=20
    local step_delay=$(echo "scale=3; $duration/$steps" | bc -l 2>/dev/null || echo "0.1")

    echo -n "${message} "

    case $style in
        1) echo -n "[" ;;
        2) echo -n "⏳ " ;;
        3) echo -n "🔄 " ;;
        4) echo -n "⚡ " ;;
    esac

    for ((i=0; i<steps; i++)); do
        case $style in
            1) echo -n "▰" ;;
            2) echo -n "░" ;;
            3) echo -n "○" ;;
            4) echo -n "►" ;;
        esac
        sleep $step_delay 2>/dev/null || sleep 0.1
    done

    case $style in
        1) echo -n "] ✓" ;;
        2) echo -n " ✓" ;;
        3) echo -n " ✓" ;;
        4) echo -n " ✓" ;;
    esac
    echo ""
}

# Random Easter egg
show_easter_egg() {
    local index=$((RANDOM % ${#EasterEggs[@]}))
    local color=$((RANDOM % 6))
    case $color in
        0) echo -e "${RED}${EasterEggs[$index]}${NC}" ;;
        1) echo -e "${GREEN}${EasterEggs[$index]}${NC}" ;;
        2) echo -e "${YELLOW}${EasterEggs[$index]}${NC}" ;;
        3) echo -e "${BLUE}${EasterEggs[$index]}${NC}" ;;
        4) echo -e "${PURPLE}${EasterEggs[$index]}${NC}" ;;
        5) echo -e "${CYAN}${EasterEggs[$index]}${NC}" ;;
    esac
}

# Animation functions
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Show banner
show_banner
echo -e "${BOLD}Jor Connector ULTIMATE Edition v2.0${NC}"
echo -e "${CYAN}The complete networking solution with style!${NC}"
echo ""

# Create package structure
echo -e "${YELLOW}📦 Creating refactored package structure...${NC}"
mkdir -p jor-conn-ultimate/DEBIAN
mkdir -p jor-conn-ultimate/usr/local/bin
mkdir -p jor-conn-ultimate/usr/local/lib/jor-conn
mkdir -p jor-conn-ultimate/etc/jor-conn/networks
mkdir -p jor-conn-ultimate/var/log/jor-conn

# Create control file
cat > jor-conn-ultimate/DEBIAN/control << 'CONTROL_EOF'
Package: jor-conn-ultimate
Version: 3.0.0
Section: net
Priority: optional
Architecture: all
Depends: bash, tigervnc-viewer, wpasupplicant, ntpdate, curl, dnsutils, bc, net-tools
Maintainer: Jor Master <jor@ultimate>
Description: Refactored VNC and Network Connection Manager
 A portable and configurable networking solution with a flexible profile system,
 ASCII art, progress bars, and remote access capabilities.
CONTROL_EOF

# Create the default configuration file that will be installed
cat > jor-conn-ultimate/etc/jor-conn/config.conf << 'CONFIG_EOF'
# Jor Connector ULTIMATE Edition - Main Configuration
#
# This file contains the global settings for all jor_conn tools.
# Edit the values to match your setup.

# Your primary wireless network interface (e.g., wlan0, wlp2s0)
INTERFACE="wlp1s0"

# Log file location
LOG_FILE="/var/log/jor-conn/jor-conn.log"

# The local IP address of your VNC server
SERVER_LOCAL="192.168.49.57"

# The remote address (e.g., DuckDNS domain) of your VNC server
SERVER_REMOTE="jelicopter.duckdns.org"

# Your DuckDNS domain (the part before .duckdns.org)
DUCKDNS_DOMAIN="jelicopter"

# Your DuckDNS token from https://duckdns.org
DUCKDNS_TOKEN="YOUR_DUCKDNS_TOKEN_HERE"

# The full address of your HTTP proxy
PROXY_SERVER="http://192.168.49.1:8228"
CONFIG_EOF

# Create pre-installation script
cat > jor-conn-ultimate/DEBIAN/preinst << 'PREINST_EOF'
#!/bin/bash
if [ "$(id -u)" -ne 0 ]; then
  echo "This package must be installed with sudo or as root." >&2
  exit 1
fi
echo "🎩 Preparing for Jor Connector ULTIMATE installation..."
echo "This will install a portable and configurable network manager!"
sleep 1
PREINST_EOF

# Create post-installation script
cat > jor-conn-ultimate/DEBIAN/postinst << 'POSTINST_EOF'
#!/bin/bash
# Ultimate post-installation script

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
cat << 'ART'
    ╔═╗╔═╗╦═╗    ╔═╗╔═╗╔╗╔╔═╗╔╦╗╔═╗╦ ╦╔╦╗
    ║║║╠═╝╠╦╝    ║ ║╠═╣║║║╠═╣║║║║ ║║ ║║║║
    ╚═╝╩  ╩╚═    ╚═╝╩ ╩╝╚╝╩ ╩╩ ╩╚═╝╚═╝╩ ╩
ART
echo -e "${NC}"

echo -e "${YELLOW}🚀 Initializing Jor Connector ULTIMATE (Refactored)...${NC}"

# Set executable permissions
chmod +x /usr/local/bin/jor_conn
chmod +x /usr/local/bin/jor-troubleshoot
chmod +x /usr/local/bin/jor-duckdns-update
chmod +x /usr/local/bin/jor-status
chmod +x /usr/local/bin/jor-magic

# Create default network profiles if they don't exist
create_default_profiles() {
    # Create network profiles directory if it doesn't exist
    mkdir -p /etc/jor-conn/networks

    if [ ! -f /etc/jor-conn/networks/noproxy ]; then
        echo "Creating example 'noproxy' network profile..."
        cat > /etc/jor-conn/networks/noproxy << 'NET_NOPROXY_EOF'
# Network Profile: noproxy
# Connects to a standard Wi-Fi network without a proxy.
WPA_CONFIG_CONTENT="""
ctrl_interface=/var/run/wpa_supplicant
update_config=1

network={
    ssid=\\"Jo\\"
    psk=\\"69696969\\"
}
"""
APPLY_PROXY="false"
NET_NOPROXY_EOF
    fi

    if [ ! -f /etc/jor-conn/networks/proxy ]; then
        echo "Creating example 'proxy' network profile..."
        cat > /etc/jor-conn/networks/proxy << 'NET_PROXY_EOF'
# Network Profile: proxy
# Connects to a Wi-Fi network and applies proxy settings.
WPA_CONFIG_CONTENT="""
ctrl_interface=/var/run/wpa_supplicant
update_config=1

network={
    ssid=\\"DIRECT-TF-thuruht\\"
    psk=\\"0thello6q\\"
}
"""
APPLY_PROXY="true"
NET_PROXY_EOF
    fi
}

create_default_profiles

# Create and set permissions for log file
touch /var/log/jor-conn/jor-conn.log
chmod 666 /var/log/jor-conn/jor-conn.log

# Final instructions
echo -e "${GREEN}"
echo "████████████████████████████████████████████████████████████"
echo "✅ JOR CONNECTOR ULTIMATE (REFACTORED) INSTALLED SUCCESSFULLY!"
echo ""
echo "✨ This version is now portable and configurable! ✨"
echo "   - Main config: /etc/jor-conn/config.conf"
echo "   - Network profiles: /etc/jor-conn/networks/"
echo ""
echo "🎯 Available commands:"
echo "   jor_conn connect <profile> - Connect to a network"
echo "   jor_conn remote-vnc      - Start smart VNC"
echo "   jor_conn status          - View system status"
echo "   jor_conn edit-config     - Edit main configuration"
echo ""
echo "🚀 Quick start:"
echo "   sudo jor_conn connect proxy"
echo "   jor_conn remote-vnc"
echo "████████████████████████████████████████████████████████████"
echo -e "${NC}"

# Log installation
echo "$(date): Jor Connector Ultimate (Refactored) installed" >> /var/log/jor-conn/jor-conn.log
POSTINST_EOF
chmod +x jor-conn-ultimate/DEBIAN/postinst
chmod +x jor-conn-ultimate/DEBIAN/preinst

# Create a shared library for common functions
echo -e "${YELLOW}📚 Creating shared library...${NC}"
cat > jor-conn-ultimate/usr/local/lib/jor-conn/shared.sh << 'SHARED_EOF'
#!/bin/bash
# Jor Connector ULTIMATE Edition - Shared Library
# Contains common functions and variables for all jor_conn scripts.

# --- Colors and Styles ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# --- Easter Egg Messages ---
EasterEggs=(
    "🌟 Jor's Legendary Connection Adventure!"
    "🚀 Turbo mode engaged! Za Warudo!"
    "💎 Diamond is Unbreakable connection!"
    "⚡ Golden Wind of data flowing!"
    "🎯 Crazy Diamond reliable connection!"
    "🌙 Stardust Crusaders network journey!"
    "🔥 Burning Down the House with speed!"
    "🌀 Made in Heaven fast connection!"
    "🎨 Greatful Dead slow connection revived!"
    "🌊 Stone Ocean smooth streaming!"
)

# --- ASCII Art Banners ---
show_banner() {
    echo -e "${PURPLE}"
    case $((RANDOM % 4)) in
        0)
            cat << 'ART'
    ██╗ ██████╗ ██████╗     ██████╗ ██████╗ ███╗   ██╗███╗   ██╗
    ██║██╔═══██╗██╔══██╗   ██╔════╝██╔═══██╗████╗  ██║████╗  ██║
    ██║██║   ██║██████╔╝   ██║     ██║   ██║██╔██╗ ██║██╔██╗ ██║
██╗ ██║██║   ██║██╔══██╗   ██║     ██║   ██║██║╚██╗██║██║╚██╗██║
╚█████╔╝╚██████╔╝██║  ██║   ╚██████╗╚██████╔╝██║ ╚████║██║ ╚████║
 ╚════╝  ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝
ART
            ;;
        1)
            cat << 'ART'
    ╦╔═╗╔═╗╦═╗    ╔═╗╔═╗╔╗╔╔═╗╔╦╗
    ║╚═╗╠═╝╠╦╝    ║ ║╠═╣║║║╠═╣║║║
    ╩╚═╝╩  ╩╚═    ╚═╝╩ ╩╝╚╝╩ ╩╩ ╩
ART
            ;;
        2)
            cat << 'ART'
    ░▒█▀▀▀█░▒█▀▀▀░▒█░░░░▒█▀▀▀░█▀▀▄░▒█▀▀▀█
    ░░▀▀▀▄▄░▒█▀▀▀░▒█░░░░▒█▀▀▀▒█▄▄█░░▀▀▀▄▄
    ░▒█▄▄▄█░▒█▄▄▄░▒█▄▄█░▒█▄▄▄▒█░▒█░▒█▄▄▄█
ART
            ;;
        3)
            cat << 'ART'
    ╔═══╗╔═╗╔═╗    ╔═╗╔═╗╔╗╔╔═╗╔╦╗
    ║╔═╗║║║╚╝║║    ║ ║╠═╣║║║╠═╣║║║
    ╚╝ ╚╝╚╩╝╚╩╝    ╚═╝╩ ╩╝╚╝╩ ╩╩ ╩
ART
            ;;
    esac
    echo -e "${NC}"
}

# --- UI Functions ---
# Animated progress bar
progress_bar() {
    local duration=${1:-2}
    local style=${2:-$((RANDOM % 4 + 1))}
    local message=${3:-"Processing..."}
    local steps=20
    local step_delay=$(echo "scale=3; $duration/$steps" | bc -l 2>/dev/null || echo "0.1")

    echo -n "${message} "
    local bar=""
    for ((i=0; i<steps; i++)); do
        case $style in
            1) bar+="█";;
            2) bar+="▒";;
            3) bar+="░";;
            4) bar+="►";;
        esac
        echo -ne "\r${message} [${bar}]"
        sleep $step_delay 2>/dev/null || sleep 0.1
    done
    echo -e " ${GREEN}✓${NC}"
}

# Random Easter egg display
show_easter_egg() {
    local index=$((RANDOM % ${#EasterEggs[@]}))
    local color_code=$((31 + RANDOM % 6))
    echo -e "\033[1;${color_code}m${EasterEggs[$index]}${NC}"
}

# --- System Functions ---
# Logging function - requires LOG_FILE to be set from config.conf
log() {
    # Ensure log file is writable
    if [ ! -w "$LOG_FILE" ]; then
        # Attempt to create it if it doesn't exist
        touch "$LOG_FILE" &>/dev/null
        chmod 666 "$LOG_FILE" &>/dev/null
        if [ ! -w "$LOG_FILE" ]; then
            # Still not writable, so don't try to log
            return
        fi
    fi
    echo "$(date): $1" >> "$LOG_FILE"
}
SHARED_EOF

# Create the refactored main script
echo -e "${YELLOW}⚡ Creating refactored jor_conn script...${NC}"
cat > jor-conn-ultimate/usr/local/bin/jor_conn << 'SCRIPT_EOF'
#!/bin/bash
# Jor Connector ULTIMATE Edition (Refactored)
# A portable and configurable networking solution.

# --- Configuration and Library Loading ---
# Load main config file first, as it defines variables needed by the library
if [ -f "/etc/jor-conn/config.conf" ]; then
    source "/etc/jor-conn/config.conf"
else
    # We can't use shared library colors here as it's not sourced yet
    echo "CRITICAL: Configuration file /etc/jor-conn/config.conf not found."
    exit 1
fi

# Source the shared library for functions and styles
source /usr/local/lib/jor-conn/shared.sh

# --- Function Definitions ---
# Function to check for root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: This command requires root privileges. Please run with sudo.${NC}"
        log "Error: Command requires root privileges."
        exit 1
    fi
}

# Network connection function
connect_network() {
    local profile_name=$1
    local profile_path="/etc/jor-conn/networks/$profile_name"

    if [ ! -f "$profile_path" ]; then
        echo -e "${RED}Error: Network profile '$profile_name' not found at $profile_path.${NC}"
        log "Error: Network profile '$profile_name' not found."
        exit 1
    fi

    show_banner
    echo -e "${YELLOW}🔌 Connecting using profile '$profile_name'...${NC}"
    log "Starting connection with profile: $profile_name"

    # Source the network profile to get its variables
    source "$profile_path"

    # Stop any existing wpa_supplicant instance
    progress_bar 1 1 "Stopping existing connections"
    killall wpa_supplicant >/dev/null 2>&1 || true
    sleep 1

    # Create a temporary wpa_supplicant config file
    local temp_wpa_config="/tmp/wpa_config_$$.conf"
    echo -e "$(eval echo "$WPA_CONFIG_CONTENT")" > "$temp_wpa_config"

    # Start the new connection
    progress_bar 2 2 "Starting network '$profile_name'"
    wpa_supplicant -B -i "$INTERFACE" -c "$temp_wpa_config"
    sleep 3 # Give it time to associate
    dhclient "$INTERFACE"
    rm "$temp_wpa_config"

    # Apply or remove proxy settings based on the profile
    if [ "$APPLY_PROXY" = "true" ]; then
        progress_bar 1 3 "Applying proxy settings"
        tee /etc/environment > /dev/null << ENV_EOF
http_proxy=${PROXY_SERVER}
https_proxy=${PROXY_SERVER}
ftp_proxy=${PROXY_SERVER}
no_proxy="localhost,127.0.0.1,192.168.0.0/16"
ENV_EOF
        log "Proxy settings applied."
    else
        progress_bar 1 3 "Removing proxy settings"
        tee /etc/environment > /dev/null << ENV_EOF
http_proxy=""
https_proxy=""
ftp_proxy=""
no_proxy="*"
ENV_EOF
        log "Proxy settings removed."
    fi

    # Sync time
    progress_bar 1 4 "Syncing time"
    ntpdate -s pool.ntp.org >/dev/null 2>&1 || true

    show_easter_egg
    echo -e "${GREEN}✅ Successfully connected using profile '$profile_name'!${NC}"
    log "Connection successful for profile '$profile_name'."
}

# DuckDNS status check
check_duckdns() {
    echo -e "${BLUE}🔍 Checking DuckDNS status...${NC}"
    local duckdns_ip=$(dig +short "$DUCKDNS_DOMAIN.duckdns.org" 2>/dev/null | head -1)
    local wan_ip=$(curl -s ifconfig.me)

    if [ -n "$duckdns_ip" ]; then
        echo -e "🌍 DuckDNS IP: $duckdns_ip"
        echo -e "📡 Your WAN IP: $wan_ip"
        if [ "$duckdns_ip" = "$wan_ip" ]; then
            echo -e "${GREEN}✅ DuckDNS is correctly pointing to your IP.${NC}"
        else
            echo -e "${YELLOW}⚠️ DuckDNS IP does not match your current WAN IP.${NC}"
        fi
    else
        echo -e "${RED}❌ Could not resolve $DUCKDNS_DOMAIN.duckdns.org.${NC}"
    fi
}

# --- Main Command Handler ---
case "$1" in
    "connect")
        check_root
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a network profile to connect to.${NC}"
            echo -e "Usage: sudo jor_conn connect <profile_name>"
            exit 1
        fi
        connect_network "$2"
        ;;

    "remote-vnc")
        show_banner
        echo -e "${YELLOW}🖥️  Initiating smart VNC connection...${NC}"
        log "Starting VNC connection"

        progress_bar 2 4 "Detecting server location"
        check_duckdns
        echo ""

        if ping -c 1 -W 2 "$SERVER_LOCAL" >/dev/null 2>&1; then
            echo -e "${GREEN}📍 Server found locally at $SERVER_LOCAL${NC}"
            log "Connecting to VNC via local network"
            vncviewer "$SERVER_LOCAL:5901"
        else
            echo -e "${BLUE}🌍 Connecting to VNC via DuckDNS: $SERVER_REMOTE${NC}"
            log "Connecting to VNC via DuckDNS"
            vncviewer "$SERVER_REMOTE:5901"
        fi
        ;;

    "status")
        show_banner
        echo -e "${CYAN}📊 Ultimate System Status:${NC}"
        echo ""
        progress_bar 1 1 "Checking network interface"
        echo -e "${YELLOW}🌐 Network Interface ($INTERFACE):${NC}"
        iw dev "$INTERFACE" link 2>/dev/null || echo -e "  ${RED}Interface not connected${NC}"
        echo ""
        progress_bar 0.5 2 "Checking IP address"
        echo -e "${YELLOW}📡 IP Address:${NC}"
        ip addr show "$INTERFACE" 2>/dev/null | grep 'inet ' | head -1 | awk '{print "  " $2}' || echo -e "  ${RED}No IP assigned${NC}"
        echo ""
        progress_bar 0.5 3 "Checking proxy settings"
        echo -e "${YELLOW}🔌 Proxy Settings:${NC}"
        env | grep -i "proxy" | grep -v "no_proxy" || echo -e "  ${GREEN}No proxy settings active${NC}"
        echo ""
        progress_bar 1 4 "Checking server status"
        echo -e "${YELLOW}🖥️  Server Status:${NC}"
        if ping -c 1 -W 2 "$SERVER_LOCAL" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✅ Local server ($SERVER_LOCAL) is reachable${NC}"
        else
            echo -e "  ${YELLOW}⚠️ Local server ($SERVER_LOCAL) is unreachable${NC}"
        fi
        echo ""
        check_duckdns
        ;;

    "edit-config")
        check_root
        echo "Opening /etc/jor-conn/config.conf with nano..."
        nano /etc/jor-conn/config.conf
        echo "Config file saved. Changes will apply on next use."
        ;;

    "log")
        echo -e "${YELLOW}📋 Connection Log:${NC}"
        tail -20 "$LOG_FILE" 2>/dev/null || echo "No log file found."
        ;;

    "help"|"--help"|"-h")
        show_banner
        echo -e "${YELLOW}📖 Jor Connector ULTIMATE (Refactored) Commands:${NC}"
        echo ""
        echo -e "${GREEN}Network Management:${NC}"
        echo "  sudo jor_conn connect <profile> - Connect using a network profile from /etc/jor-conn/networks/"
        echo ""
        echo -e "${BLUE}Remote Access:${NC}"
        echo "  jor_conn remote-vnc            - Smart VNC connection (local/remote auto-detect)"
        echo ""
        echo -e "${CYAN}Monitoring & Config:${NC}"
        echo "  jor_conn status                 - Complete system and network status"
        echo "  jor_conn log                    - View the last 20 log entries"
        echo "  sudo jor_conn edit-config       - Edit the main configuration file"
        echo ""
        echo -e "${PURPLE}Advanced:${NC}"
        echo "  jor-duckdns-update              - Manually update your DuckDNS IP"
        echo "  jor-troubleshoot                - Launch advanced diagnostics script"
        echo "  jor-magic                       - ✨ Display a random Easter egg"
        echo ""
        show_easter_egg
        ;;

    *)
        show_banner
        echo -e "${YELLOW}Usage: jor_conn {connect|remote-vnc|status|help}${NC}"
        echo "For connecting, use: sudo jor_conn connect <profile_name>"
        echo "For help, use: jor_conn help"
        echo ""
        show_easter_egg
        ;;
esac

# Log command execution
log "Command executed: jor_conn $*"
SCRIPT_EOF

# Create troubleshooting script
cat > jor-conn-ultimate/usr/local/bin/jor-troubleshoot << 'TROUBLESHOOT_EOF'
#!/bin/bash
# Advanced Troubleshooting Script
source /usr/local/lib/jor-conn/shared.sh
source /etc/jor-conn/config.conf

echo -e "${YELLOW}🔧 Jor Connector Advanced Troubleshooting${NC}"
echo "===================================="

echo "1. Network Interface Check ($INTERFACE)..."
ip link show "$INTERFACE"

echo -e "\n2. WiFi Connection Status..."
iw dev "$INTERFACE" link

echo -e "\n3. IP Address Assignment..."
ip addr show "$INTERFACE"

echo -e "\n4. Routing Table..."
ip route

echo -e "\n5. DNS Resolution..."
nslookup google.com

echo -e "\n6. DuckDNS Check..."
nslookup "$DUCKDNS_DOMAIN.duckdns.org"

echo -e "\n7. VNC Port Check (Local)..."
if nc -zv -w 2 "$SERVER_LOCAL" 5901; then
    echo -e "${GREEN}Port 5901 is open on $SERVER_LOCAL${NC}"
else
    echo -e "${RED}Port 5901 is closed or unreachable on $SERVER_LOCAL${NC}"
fi

echo -e "\nTroubleshooting complete!"
TROUBLESHOOT_EOF

# Create additional utility scripts
cat > jor-conn-ultimate/usr/local/bin/jor-status << 'STATUS_EOF'
#!/bin/bash
# Quick status check
/usr/local/bin/jor_conn status
STATUS_EOF

cat > jor-conn-ultimate/usr/local/bin/jor-magic << 'MAGIC_EOF'
#!/bin/bash
# Easter egg collection
source /usr/local/lib/jor-conn/shared.sh
show_banner
echo -e "${PURPLE}🔮 Performing connection magic...${NC}"
progress_bar 2 4 "Casting network spells"
show_easter_egg
echo -e "${GREEN}✨ Magic complete! Your connections are now enchanted!${NC}"
MAGIC_EOF

cat > jor-conn-ultimate/usr/local/bin/jor-duckdns-update << 'DUCKDNS_EOF'
#!/bin/bash
# DuckDNS Manual Update Script
source /usr/local/lib/jor-conn/shared.sh
source /etc/jor-conn/config.conf

echo "Updating DuckDNS for domain: $DUCKDNS_DOMAIN..."
response=$(curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&verbose=true")
echo "DuckDNS Server Response: $response"
log "Manual DuckDNS update triggered. Response: $response"
DUCKDNS_EOF

# Set permissions
chmod +x jor-conn-ultimate/usr/local/bin/*

# Build the ultimate package
echo -e "${YELLOW}🏗️  Building refactored Debian package...${NC}"
dpkg-deb --build jor-conn-ultimate

# Final celebration message
echo -e "${GREEN}"
cat << 'CELEBRATION'
╔════════════════════════════════════════════════════════════╗
║              🎉 REFACTORED BUILD COMPLETE! 🎉              ║
║                                                            ║
║    Jor Connector ULTIMATE (Refactored) has been built.     ║
║                                                            ║
║    This new version is now:                                ║
║    ✅ Fully configurable via /etc/jor-conn/config.conf     ║
║    ✅ Easily extensible with network profiles              ║
║    ✅ Cleaner, safer, and more maintainable code           ║
║                                                            ║
║    To install, run:                                        ║
║      ${BOLD}sudo dpkg -i jor-conn-ultimate.deb${GREEN}                  ║
║                                                            ║
║    After installation, be sure to:                         ║
║    1. Edit ${BOLD}/etc/jor-conn/config.conf${GREEN} to match your setup.  ║
║    2. Customize network profiles in ${BOLD}/etc/jor-conn/networks/${GREEN} ║
║                                                            ║
║    Example usage:                                          ║
║      ${BOLD}sudo jor_conn connect proxy${GREEN}                         ║
║      ${BOLD}jor_conn status${GREEN}                                     ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
CELEBRATION
echo -e "${NC}"

echo -e "${YELLOW}📦 Package file: jor-conn-ultimate.deb${NC}"
echo -e "${CYAN}🚀 Install with: sudo dpkg -i jor-conn-ultimate.deb${NC}"

# Create the updated README file
cat > README.md << 'README_EOF'
# Jor Connector ULTIMATE Edition (Refactored)

This is a complete overhaul of the original Jor Connector, rebuilt from the ground up to be portable, configurable, and easy to maintain. It's a powerful command-line tool for managing network connections and remote access on Debian-based systems.

## Key Features
- **Central Configuration**: All settings are managed in a single file: `/etc/jor-conn/config.conf`. No more hardcoded values.
- **Flexible Network Profiles**: Add, remove, or modify network connections by simply creating text files in `/etc/jor-conn/networks/`.
- **Safe and Clean**: All `sudo` calls inside the scripts have been removed. The tool now prompts for root privileges only when needed.
- **Modular Code**: Common functions are stored in a shared library, making the code clean and easy to update.
- **All the Fun Stuff**: Still includes the original ASCII art, progress bars, and Easter eggs!

## Installation

1.  **Build the Package**:
    ```bash
    cd jor_conn_ultimate
    ./create_ultimate_package.sh
    ```

2.  **Install the Package**:
    ```bash
    sudo dpkg -i jor-conn-ultimate.deb
    ```

## Configuration

This is the most important step! After installing, you **must** edit the main configuration file to match your system and network.

```bash
# Open the config file for editing
sudo jor_conn edit-config
```

You will need to set your network interface, VNC server addresses, DuckDNS token, and more. The file is heavily commented to guide you.

## How to Use

### Network Profiles

The core of this tool is the network profile system. Profiles are simple text files located in `/etc/jor-conn/networks/`. Two examples (`noproxy` and `proxy`) are created automatically on installation.

You can create a new profile for any Wi-Fi network. For example, to create a profile for a network named "MyHomeWiFi":

1.  Create a new file: `sudo nano /etc/jor-conn/networks/home`
2.  Add the following content, adjusting the SSID and PSK:
    ```ini
    # Profile for home network
    WPA_CONFIG_CONTENT="""
    network={
        ssid=\\"MyHomeWiFi\\"
        psk=\\"MyPassword123\\"
    }
    """
    APPLY_PROXY="false"
    ```

### Available Commands

- `sudo jor_conn connect <profile_name>`: Connect to a network using a specific profile.
- `jor_conn status`: Display a full status of your network, proxy, and server connections.
- `jor_conn remote-vnc`: Launch a smart VNC connection that auto-detects if the server is local or remote.
- `sudo jor_conn edit-config`: A shortcut to open the main configuration file for editing.
- `jor-duckdns-update`: Manually trigger an update for your DuckDNS domain.
- `jor-troubleshoot`: Run a series of diagnostic checks.

This refactored version is designed to be a solid foundation that you can easily build upon. Enjoy!
README_EOF
