#!/bin/bash
# Installer for Jor-Conn CLI

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run as root."
    exit 1
fi

echo "Installing Jor-Conn..."

# 1. Install Libs
mkdir -p /usr/local/lib/jor-conn
cp lib/shared.sh /usr/local/lib/jor-conn/
chmod 644 /usr/local/lib/jor-conn/shared.sh

# 2. Install Executable
cp jor /usr/local/bin/jor
chmod 755 /usr/local/bin/jor

# 3. Install Configs
mkdir -p /etc/jor-conn/networks
if [ ! -f /etc/jor-conn/config.conf ]; then
    cp config/jor.conf /etc/jor-conn/config.conf
    chmod 644 /etc/jor-conn/config.conf
else
    echo "  Config file exists, skipping overwrite."
fi

# Copy sample networks if directory is empty
if [ -z "$(ls -A /etc/jor-conn/networks)" ]; then
    cp config/networks/* /etc/jor-conn/networks/
    chmod 700 /etc/jor-conn/networks/*
fi
chmod 700 /etc/jor-conn/networks

echo "✅ Installation Complete!"
echo "Run 'sudo jor help' to get started."
