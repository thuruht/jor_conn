#!/bin/bash
# Jor Connector - Builder Script
# This script generates the source code and builds the .deb package.

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}📦 Initializing Jor Connector Build...${NC}"

# 1. Cleanup Previous Builds
rm -rf jor-conn
rm -f jor-conn.deb

# 2. Create Directory Structure
mkdir -p jor-conn/DEBIAN
mkdir -p jor-conn/usr/local/bin
mkdir -p jor-conn/usr/local/lib/jor-conn
mkdir -p jor-conn/etc/jor-conn/networks
mkdir -p jor-conn/var/log/jor-conn

# 3. Generate CONTROL File
cat > jor-conn/DEBIAN/control << 'EOF'
Package: jor-conn
Version: 3.1.0
Section: net
Priority: optional
Architecture: all
Depends: bash, wpasupplicant, ntpdate, curl, dnsutils, bc, net-tools, nmap
Maintainer: Jor Master <jor@connector>
Description: Network & Proxy Manager
 A portable tool for managing Wi-Fi profiles and System-Wide Proxies.
 Features robust handling of APT, Git, NPM, and VS Code proxy settings.
 Includes optional tools for VNC remote access and DuckDNS management.
EOF

# 4. Generate Configuration File
cat > jor-conn/etc/jor-conn/config.conf << 'EOF'
# Jor Connector - Main Configuration
INTERFACE="wlp1s0"
LOG_FILE="/var/log/jor-conn/jor-conn.log"
SERVER_LOCAL="192.168.49.57"
SERVER_REMOTE="jelicopter.duckdns.org"
DUCKDNS_DOMAIN="jelicopter"
DUCKDNS_TOKEN="YOUR_DUCKDNS_TOKEN_HERE"
PROXY_SERVER="http://192.168.49.1:8228"
EOF

# 5. Generate SHARED LIBRARY (With Proxy Logic + Utils)
cat > jor-conn/usr/local/lib/jor-conn/shared.sh << 'EOF'
#!/bin/bash
# Jor Connector Shared Library

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

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

progress_bar() {
    local duration=${1:-2}
    local message=${2:-"Processing..."}
    local steps=20
    local step_delay=$(echo "scale=3; $duration/$steps" | bc -l 2>/dev/null || echo "0.1")
    echo -n "${message} "
    for ((i=0; i<steps; i++)); do echo -n "▓"; sleep $step_delay 2>/dev/null; done
    echo -e " ${GREEN}✓${NC}"
}

log() {
    [ -d "/var/log/jor-conn" ] || mkdir -p /var/log/jor-conn
    echo "$(date): $1" >> "$LOG_FILE"
}

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

enable_proxy_system() {
    local PROXY_URL="$PROXY_SERVER"
    local REAL_USER="$SUDO_USER"
    if [ -z "$REAL_USER" ]; then REAL_USER=$(whoami); fi
    local REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

    log "Enabling Proxy: $PROXY_URL for user $REAL_USER"
    echo -e "${CYAN}Applying system-wide proxy settings...${NC}"

    # 1. /etc/environment
    tee /etc/environment > /dev/null <<ENV_EOF
http_proxy="${PROXY_URL}"
https_proxy="${PROXY_URL}"
ftp_proxy="${PROXY_URL}"
no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,${DUCKDNS_DOMAIN}.duckdns.org"
HTTP_PROXY="${PROXY_URL}"
HTTPS_PROXY="${PROXY_URL}"
FTP_PROXY="${PROXY_URL}"
NO_PROXY="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,${DUCKDNS_DOMAIN}.duckdns.org"
ENV_EOF

    # 2. Bashrc
    local BASHRC="$REAL_HOME/.bashrc"
    if ! grep -q "JOR_CONN_PROXY" "$BASHRC"; then
        cat >> "$BASHRC" <<BASH_EOF

# JOR_CONN_PROXY_START
export http_proxy="${PROXY_URL}"
export https_proxy="${PROXY_URL}"
export ftp_proxy="${PROXY_URL}"
export no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8"
# JOR_CONN_PROXY_END
BASH_EOF
    fi

    # 3. APT
    echo "Acquire::http::Proxy \"${PROXY_URL}/\";" | tee /etc/apt/apt.conf.d/99jorproxy /etc/apt/apt.conf.d/02proxy > /dev/null
    echo "Acquire::https::Proxy \"${PROXY_URL}/\";" | tee -a /etc/apt/apt.conf.d/99jorproxy /etc/apt/apt.conf.d/02proxy > /dev/null
    echo -e "${GREEN}✅ APT Proxy Configured.${NC}"

    # 4. Git & NPM
    if command -v git &>/dev/null; then
        sudo -u "$REAL_USER" git config --global http.proxy "$PROXY_URL"
        sudo -u "$REAL_USER" git config --global https.proxy "$PROXY_URL"
    fi
    if command -v npm &>/dev/null; then
        sudo -u "$REAL_USER" npm config set proxy "$PROXY_URL"
        sudo -u "$REAL_USER" npm config set https-proxy "$PROXY_URL"
    fi

    # 5. Check for jq (Interactive)
    if ! command -v jq &>/dev/null; then
        echo -e "${YELLOW}⚠️  'jq' is missing! It is needed for VS Code config.${NC}"
        echo -e "${YELLOW}APT proxy is active. We can install it now.${NC}"
        echo -n "👉 Run 'apt install jq' now? [y/N]: "
        read -r INSTALL_JQ
        if [[ "$INSTALL_JQ" =~ ^[Yy]$ ]]; then
            apt update && apt install -y jq
        fi
    fi

    # 6. VS Code
    update_vscode_json() {
        local settings_file="$1"
        if [ -f "$settings_file" ] && command -v jq &>/dev/null; then
            tmp=$(mktemp)
            jq --arg proxy "$PROXY_URL" '. + {"http.proxy": $proxy, "http.proxyStrictSSL": false}' "$settings_file" > "$tmp" && mv "$tmp" "$settings_file"
            rm -f "$tmp"
            chown "$REAL_USER":"$REAL_USER" "$settings_file"
            echo -e "${GREEN}✅ VS Code settings updated.${NC}"
        fi
    }
    update_vscode_json "$REAL_HOME/.config/Code/User/settings.json"
    update_vscode_json "$REAL_HOME/.config/VSCodium/User/settings.json"

    # 7. SSH Instructions
    local proxy_host_port=$(echo "${PROXY_URL}" | sed -e 's#http[s]*://##')
    echo -e "${YELLOW}Developer tools configuration:${NC}"
    echo -e "To tunnel SSH over the proxy, add this to your ${BOLD}~/.ssh/config${NC} file:"
    echo -e "  ${CYAN}Host *${NC}"
    echo -e "    ${CYAN}ProxyCommand /usr/bin/ncat --proxy-type http --proxy ${proxy_host_port} %h %p${NC}"

    echo -e "${GREEN}✅ Proxy Enabled System-Wide.${NC}"
}

disable_proxy_system() {
    local REAL_USER="$SUDO_USER"
    if [ -z "$REAL_USER" ]; then REAL_USER=$(whoami); fi
    local REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

    log "Disabling Proxy"

    # Clear Environment
    tee /etc/environment > /dev/null <<ENV_EOF
http_proxy=""
https_proxy=""
ftp_proxy=""
no_proxy=""
ENV_EOF

    # Clear Bashrc
    sed -i '/# JOR_CONN_PROXY_START/,/# JOR_CONN_PROXY_END/d' "$REAL_HOME/.bashrc"

    # Clear APT
    rm -f /etc/apt/apt.conf.d/99jorproxy
    echo "" > /etc/apt/apt.conf.d/02proxy

    # Clear Git/NPM
    sudo -u "$REAL_USER" git config --global --unset http.proxy 2>/dev/null
    sudo -u "$REAL_USER" npm config delete proxy 2>/dev/null

    # Clear VS Code
    clear_vscode_json() {
        local settings_file="$1"
        if [ -f "$settings_file" ] && command -v jq &>/dev/null; then
            tmp=$(mktemp)
            jq 'del(."http.proxy") | del(."http.proxyStrictSSL")' "$settings_file" > "$tmp" && mv "$tmp" "$settings_file"
            rm -f "$tmp"
            chown "$REAL_USER":"$REAL_USER" "$settings_file"
        fi
    }
    clear_vscode_json "$REAL_HOME/.config/Code/User/settings.json"
    clear_vscode_json "$REAL_HOME/.config/VSCodium/User/settings.json"

    echo -e "${GREEN}✅ Proxy Disabled.${NC}"
}
EOF

# 6. Generate MAIN EXECUTABLE
cat > jor-conn/usr/local/bin/jor_conn << 'EOF'
#!/bin/bash
# Jor Connector Controller

if [ -f "/etc/jor-conn/config.conf" ]; then
    source "/etc/jor-conn/config.conf"
else
    echo "CRITICAL: /etc/jor-conn/config.conf not found."
    exit 1
fi

source /usr/local/lib/jor-conn/shared.sh

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: Run with sudo.${NC}"
        exit 1
    fi
}

connect_network() {
    local profile_name=$1
    local profile_path="/etc/jor-conn/networks/$profile_name"

    if [ ! -f "$profile_path" ]; then
        echo -e "${RED}Error: Profile '$profile_name' not found.${NC}"
        exit 1
    fi

    show_banner
    log "Connecting: $profile_name"
    source "$profile_path"

    progress_bar 1 "Stopping old connections"
    killall wpa_supplicant >/dev/null 2>&1 || true
    sleep 1

    local temp_wpa="/tmp/wpa_config_$$.conf"
    echo -e "$(eval echo "$WPA_CONFIG_CONTENT")" > "$temp_wpa"

    progress_bar 2 "Starting $profile_name"
    wpa_supplicant -B -i "$INTERFACE" -c "$temp_wpa"
    sleep 3
    dhclient "$INTERFACE"
    rm "$temp_wpa"

    if [ "$APPLY_PROXY" = "true" ]; then
        enable_proxy_system
    else
        disable_proxy_system
    fi

    progress_bar 1 "Syncing time"
    ntpdate -s pool.ntp.org >/dev/null 2>&1 || true
    echo -e "${GREEN}✅ Connected!${NC}"
}

case "$1" in
    "connect")
        check_root
        [ -z "$2" ] && echo "Usage: sudo jor_conn connect <profile>" && exit 1
        connect_network "$2"
        ;;
    "proxy")
        check_root
        if [ "$2" == "on" ]; then show_banner; enable_proxy_system;
        elif [ "$2" == "off" ]; then show_banner; disable_proxy_system;
        else echo "Usage: sudo jor_conn proxy {on|off}"; fi
        ;;
    "remote-vnc")
        show_banner
        # Check if vncviewer exists (Client-side feature)
        if ! command -v vncviewer &>/dev/null; then
             echo -e "${YELLOW}⚠️  'vncviewer' is missing!${NC}"
             echo -n "👉 Run 'apt install tigervnc-viewer' now? [y/N]: "
             read -r INSTALL_VNC
             if [[ "$INSTALL_VNC" =~ ^[Yy]$ ]]; then
                 # Try to use apt if sudo is available, else warn
                 if [ "$(id -u)" -eq 0 ]; then
                    apt update && apt install -y tigervnc-viewer
                 else
                    sudo apt update && sudo apt install -y tigervnc-viewer
                 fi
             else
                 echo "Aborting VNC connection."
                 exit 1
             fi
        fi

        echo -e "${YELLOW}🖥️  Initiating smart VNC connection...${NC}"
        log "Starting VNC connection"

        progress_bar 2 "Detecting server location"
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
        echo -e "${CYAN}📊 System Status:${NC}"
        echo ""
        echo -e "${YELLOW}🌐 Network Interface ($INTERFACE):${NC}"
        iw dev "$INTERFACE" link 2>/dev/null || echo -e "  ${RED}Interface not connected${NC}"
        echo ""
        echo -e "${YELLOW}📡 IP Address:${NC}"
        ip addr show "$INTERFACE" 2>/dev/null | grep 'inet ' | head -1 | awk '{print "  " $2}' || echo -e "  ${RED}No IP assigned${NC}"
        echo ""
        echo -e "${YELLOW}🔌 Proxy Settings:${NC}"
        env | grep -i "proxy" | grep -v "no_proxy" || echo -e "  ${GREEN}No proxy settings active${NC}"
        echo ""
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
        nano /etc/jor-conn/config.conf
        ;;
    *)
        show_banner
        echo "Usage: jor_conn {connect <profile> | proxy {on|off} | remote-vnc | status | edit-config}"
        ;;
esac
EOF

# 7. Create Default Profiles
mkdir -p jor-conn/etc/jor-conn/networks
cat > jor-conn/etc/jor-conn/networks/proxy << 'EOF'
WPA_CONFIG_CONTENT="""
network={
    ssid=\\"DIRECT-TF-thuruht\\"
    psk=\\"0thello6q\\"
}
"""
APPLY_PROXY="true"
EOF

cat > jor-conn/etc/jor-conn/networks/noproxy << 'EOF'
WPA_CONFIG_CONTENT="""
network={
    ssid=\\"Jo\\"
    psk=\\"69696969\\"
}
"""
APPLY_PROXY="false"
EOF

# 8. Create Troubleshooting & Utility Scripts
cat > jor-conn/usr/local/bin/jor-troubleshoot << 'EOF'
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
if command -v ncat >/dev/null; then
    if ncat -zv -w 2 "$SERVER_LOCAL" 5901 2>/dev/null; then
        echo -e "${GREEN}Port 5901 is open on $SERVER_LOCAL${NC}"
    else
        echo -e "${RED}Port 5901 is closed or unreachable on $SERVER_LOCAL${NC}"
    fi
elif command -v nc >/dev/null; then
     if nc -zv -w 2 "$SERVER_LOCAL" 5901 2>/dev/null; then
        echo -e "${GREEN}Port 5901 is open on $SERVER_LOCAL${NC}"
    else
        echo -e "${RED}Port 5901 is closed or unreachable on $SERVER_LOCAL${NC}"
    fi
else
    echo "ncat/nc not found, skipping port check."
fi

echo -e "\nTroubleshooting complete!"
EOF

cat > jor-conn/usr/local/bin/jor-duckdns-update << 'EOF'
#!/bin/bash
# DuckDNS Manual Update Script
source /usr/local/lib/jor-conn/shared.sh
source /etc/jor-conn/config.conf

echo "Updating DuckDNS for domain: $DUCKDNS_DOMAIN..."
if [ -z "$DUCKDNS_TOKEN" ] || [ "$DUCKDNS_TOKEN" == "YOUR_DUCKDNS_TOKEN_HERE" ]; then
    echo -e "${RED}Error: DuckDNS token not configured in /etc/jor-conn/config.conf${NC}"
    exit 1
fi
response=$(curl -s "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&verbose=true")
echo "DuckDNS Server Response: $response"
log "Manual DuckDNS update triggered. Response: $response"
EOF

cat > jor-conn/usr/local/bin/jor-status << 'EOF'
#!/bin/bash
# Quick status check for Jor-Conn
/usr/local/bin/jor_conn status
EOF

# 9. Create Post-Install Script
cat > jor-conn/DEBIAN/postinst << 'EOF'
#!/bin/bash
chmod +x /usr/local/bin/jor_conn
chmod +x /usr/local/bin/jor-troubleshoot
chmod +x /usr/local/bin/jor-duckdns-update
chmod +x /usr/local/bin/jor-status
chmod +x /usr/local/lib/jor-conn/shared.sh
echo "✅ Jor Connector Installed!"
echo "👉 Run 'sudo jor_conn edit-config' to set up your IPs."
EOF
chmod 755 jor-conn/DEBIAN/postinst

# 10. Set Permissions and Build
chmod 755 jor-conn/usr/local/bin/*
chmod 755 jor-conn/usr/local/lib/jor-conn/*

echo -e "${GREEN}🔨 Building .deb package...${NC}"
dpkg-deb --build jor-conn

echo -e "${GREEN}✅ Build Complete: jor-conn.deb${NC}"
echo "👉 Install with: sudo dpkg -i jor-conn.deb"
