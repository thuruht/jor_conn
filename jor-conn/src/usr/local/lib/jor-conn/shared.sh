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
export MAVEN_OPTS="-Dhttp.proxyHost=$(echo $PROXY_URL | sed 's|^http://||' | cut -d: -f1) -Dhttp.proxyPort=$(echo $PROXY_URL | sed 's|^http://||' | cut -d: -f2) -Dhttps.proxyHost=$(echo $PROXY_URL | sed 's|^http://||' | cut -d: -f1) -Dhttps.proxyPort=$(echo $PROXY_URL | sed 's|^http://||' | cut -d: -f2)"
# JOR_CONN_PROXY_END
BASH_EOF
    fi

    # 3. APT
    mkdir -p /etc/apt/apt.conf.d
    echo "Acquire::http::Proxy \"${PROXY_URL}/\";" | tee /etc/apt/apt.conf.d/99jorproxy /etc/apt/apt.conf.d/02proxy > /dev/null
    echo "Acquire::https::Proxy \"${PROXY_URL}/\";" | tee -a /etc/apt/apt.conf.d/99jorproxy /etc/apt/apt.conf.d/02proxy > /dev/null
    echo -e "${GREEN}✅ APT Proxy Configured.${NC}"

    # 4. Git & NPM
    if command -v git &>/dev/null; then
        sudo -u "$REAL_USER" git config --global http.proxy "$PROXY_URL"
        sudo -u "$REAL_USER" git config --global https.proxy "$PROXY_URL"
        # Force HTTPS instead of git:// to bypass firewalls blocking port 9418
        sudo -u "$REAL_USER" git config --global url."https://".insteadOf git://
        echo -e "${GREEN}✅ Git Proxy Configured (HTTP/HTTPS/Protocol Swap).${NC}"
    fi
    if command -v npm &>/dev/null; then
        sudo -u "$REAL_USER" npm config set proxy "$PROXY_URL"
        sudo -u "$REAL_USER" npm config set https-proxy "$PROXY_URL"
        # Disable strict-ssl to avoid certificate issues behind proxies
        sudo -u "$REAL_USER" npm config set strict-ssl false
        echo -e "${GREEN}✅ NPM Proxy Configured.${NC}"
    fi

    # 5. Gradle (User-level)
    local GRADLE_PROPS="$REAL_HOME/.gradle/gradle.properties"
    local GRADLE_DIR=$(dirname "$GRADLE_PROPS")
    if [ ! -d "$GRADLE_DIR" ]; then
        mkdir -p "$GRADLE_DIR"
        chown "$REAL_USER":"$REAL_USER" "$GRADLE_DIR"
    fi

    # Clean old Jor-Conn blocks if any
    if [ -f "$GRADLE_PROPS" ]; then
        sed -i '/# JOR_CONN_PROXY_START/,/# JOR_CONN_PROXY_END/d' "$GRADLE_PROPS"
    fi

    local PROXY_HOST=$(echo "$PROXY_URL" | sed -e 's|^[^/]*//||' -e 's|:.*$||')
    local PROXY_PORT=$(echo "$PROXY_URL" | sed -e 's|^.*:||' -e 's|/.*$||')

    cat >> "$GRADLE_PROPS" <<GRADLE_EOF
# JOR_CONN_PROXY_START
systemProp.http.proxyHost=${PROXY_HOST}
systemProp.http.proxyPort=${PROXY_PORT}
systemProp.https.proxyHost=${PROXY_HOST}
systemProp.https.proxyPort=${PROXY_PORT}
# JOR_CONN_PROXY_END
GRADLE_EOF
    chown "$REAL_USER":"$REAL_USER" "$GRADLE_PROPS"
    echo -e "${GREEN}✅ Gradle Proxy Configured.${NC}"

    # 6. Wget (added per user request)
    local WGETRC="$REAL_HOME/.wgetrc"
    if ! grep -q "JOR_CONN_PROXY" "$WGETRC" 2>/dev/null; then
        cat >> "$WGETRC" <<WGET_EOF
# JOR_CONN_PROXY_START
use_proxy=yes
http_proxy=${PROXY_URL}
https_proxy=${PROXY_URL}
ftp_proxy=${PROXY_URL}
# JOR_CONN_PROXY_END
WGET_EOF
        chown "$REAL_USER":"$REAL_USER" "$WGETRC"
        echo -e "${GREEN}✅ Wget Proxy Configured.${NC}"
    fi

    # 6. Check for jq (Interactive)
    if ! command -v jq &>/dev/null; then
        echo -e "${YELLOW}⚠️  'jq' is missing! It is needed for VS Code config.${NC}"
        echo -e "${YELLOW}APT proxy is active. We can install it now.${NC}"
        # Non-interactive mode preference: just warn if missing, don't block
        echo -e "${YELLOW}Skipping jq installation prompt (install manually if needed).${NC}"
    fi

    # 7. VS Code
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

    # 8. Docker (Daemon + Client)
    if command -v docker &>/dev/null; then
        # Daemon Config (Systemd)
        if [ -d "/etc/systemd/system" ]; then
            mkdir -p /etc/systemd/system/docker.service.d
            cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<DOCKER_EOF
[Service]
Environment="HTTP_PROXY=${PROXY_URL}"
Environment="HTTPS_PROXY=${PROXY_URL}"
Environment="NO_PROXY=localhost,127.0.0.1,::1,${DUCKDNS_DOMAIN}.duckdns.org"
DOCKER_EOF
            systemctl daemon-reload && systemctl restart docker
            echo -e "${GREEN}✅ Docker Daemon Proxy Configured.${NC}"
        fi

        # Client Config (~/.docker/config.json)
        mkdir -p "$REAL_HOME/.docker"
        local DOCKER_CONF="$REAL_HOME/.docker/config.json"
        if [ ! -f "$DOCKER_CONF" ]; then echo "{}" > "$DOCKER_CONF"; chown "$REAL_USER":"$REAL_USER" "$DOCKER_CONF"; fi

        # Use simple sed injection if jq is missing, else jq
        if command -v jq &>/dev/null; then
            tmp=$(mktemp)
            jq --arg proxy "$PROXY_URL" '.proxies.default = {"httpProxy": $proxy, "httpsProxy": $proxy, "noProxy": "localhost,127.0.0.1"}' "$DOCKER_CONF" > "$tmp" && mv "$tmp" "$DOCKER_CONF"
            rm -f "$tmp"
            chown "$REAL_USER":"$REAL_USER" "$DOCKER_CONF"
        fi
        echo -e "${GREEN}✅ Docker Client Proxy Configured.${NC}"
    fi

    # 9. GNOME Desktop (gsettings)
    if command -v gsettings &>/dev/null; then
         # We need to run dbus-launch to access dconf if run from sudo
         # But usually 'sudo -u user gsettings' works if user is logged in
         sudo -u "$REAL_USER" dbus-launch gsettings set org.gnome.system.proxy mode 'manual' 2>/dev/null
         local HOST=$(echo "$PROXY_URL" | sed -e 's|^[^/]*//||' -e 's|:.*$||')
         local PORT=$(echo "$PROXY_URL" | sed -e 's|^.*:||' -e 's|/.*$||')
         sudo -u "$REAL_USER" dbus-launch gsettings set org.gnome.system.proxy.http host "$HOST" 2>/dev/null
         sudo -u "$REAL_USER" dbus-launch gsettings set org.gnome.system.proxy.http port "$PORT" 2>/dev/null
         sudo -u "$REAL_USER" dbus-launch gsettings set org.gnome.system.proxy.https host "$HOST" 2>/dev/null
         sudo -u "$REAL_USER" dbus-launch gsettings set org.gnome.system.proxy.https port "$PORT" 2>/dev/null
         echo -e "${GREEN}✅ GNOME Desktop Proxy Configured.${NC}"
    fi

    # 10. SSH Instructions
    local proxy_host_port=$(echo "${PROXY_URL}" | sed -e 's#http[s]*://##')
    echo -e "${YELLOW}Developer tools configuration:${NC}"
    echo -e "To tunnel SSH over the proxy, add this to your ${BOLD}~/.ssh/config${NC} file:"
    echo -e "  ${CYAN}Host *${NC}"
    echo -e "    ${CYAN}ProxyCommand /usr/bin/ncat --proxy-type http --proxy ${proxy_host_port} %h %p${NC}"

    echo -e "${GREEN}✅ Proxy Enabled System-Wide.${NC}"
}

inject_proxy_to_chroot() {
    local TARGET_ROOT="$1"
    local PROXY_URL="$PROXY_SERVER"

    if [ -z "$TARGET_ROOT" ] || [ ! -d "$TARGET_ROOT" ]; then
        echo -e "${RED}Error: Invalid target chroot directory: $TARGET_ROOT${NC}"
        return 1
    fi

    echo -e "${CYAN}💉 Injecting proxy settings into chroot: $TARGET_ROOT${NC}"

    # 1. Inject /etc/environment
    local TARGET_ENV="$TARGET_ROOT/etc/environment"
    if [ -f "$TARGET_ENV" ]; then
        # Check if already present to avoid duplication
        if ! grep -q "http_proxy" "$TARGET_ENV"; then
            cat >> "$TARGET_ENV" <<ENV_EOF
http_proxy="${PROXY_URL}"
https_proxy="${PROXY_URL}"
ftp_proxy="${PROXY_URL}"
no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,${DUCKDNS_DOMAIN}.duckdns.org"
ENV_EOF
            echo -e "  ${GREEN}✓ Environment variables injected${NC}"
        else
             echo -e "  ${YELLOW}⚠ Environment variables already present in target${NC}"
        fi
    fi

    # 2. Inject APT Config
    local TARGET_APT_DIR="$TARGET_ROOT/etc/apt/apt.conf.d"
    if [ -d "$TARGET_APT_DIR" ]; then
        echo "Acquire::http::Proxy \"${PROXY_URL}/\";" > "$TARGET_APT_DIR/99jorproxy"
        echo "Acquire::https::Proxy \"${PROXY_URL}/\";" >> "$TARGET_APT_DIR/99jorproxy"
        echo -e "  ${GREEN}✓ APT configuration injected${NC}"
    else
        echo -e "  ${YELLOW}⚠ Target has no /etc/apt/apt.conf.d, skipping APT config${NC}"
    fi

    echo -e "${GREEN}✅ Injection Complete.${NC}"
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
    sudo -u "$REAL_USER" git config --global --unset https.proxy 2>/dev/null
    sudo -u "$REAL_USER" git config --global --unset url."https://".insteadOf 2>/dev/null
    sudo -u "$REAL_USER" npm config delete proxy 2>/dev/null
    sudo -u "$REAL_USER" npm config delete https-proxy 2>/dev/null
    sudo -u "$REAL_USER" npm config delete strict-ssl 2>/dev/null

    # Clear Gradle
    local GRADLE_PROPS="$REAL_HOME/.gradle/gradle.properties"
    if [ -f "$GRADLE_PROPS" ]; then
        sed -i '/# JOR_CONN_PROXY_START/,/# JOR_CONN_PROXY_END/d' "$GRADLE_PROPS"
    fi

    # Clear Wget
    local WGETRC="$REAL_HOME/.wgetrc"
    if [ -f "$WGETRC" ]; then
        sed -i '/# JOR_CONN_PROXY_START/,/# JOR_CONN_PROXY_END/d' "$WGETRC"
    fi

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

    # Clear Docker
    if [ -f "/etc/systemd/system/docker.service.d/http-proxy.conf" ]; then
        rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
        systemctl daemon-reload && systemctl restart docker
    fi
    local DOCKER_CONF="$REAL_HOME/.docker/config.json"
    if [ -f "$DOCKER_CONF" ] && command -v jq &>/dev/null; then
        tmp=$(mktemp)
        jq 'del(.proxies)' "$DOCKER_CONF" > "$tmp" && mv "$tmp" "$DOCKER_CONF"
        rm -f "$tmp"
        chown "$REAL_USER":"$REAL_USER" "$DOCKER_CONF"
    fi

    # Clear GNOME
    if command -v gsettings &>/dev/null; then
         sudo -u "$REAL_USER" dbus-launch gsettings set org.gnome.system.proxy mode 'none' 2>/dev/null
    fi

    echo -e "${GREEN}✅ Proxy Disabled.${NC}"
}