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
