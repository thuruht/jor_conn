#!/bin/bash
# Build script for Jor-Conn

set -e # Exit on error

# --- Color Definitions ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'
COLOR_BOLD='\033[1m'

# --- Script Variables ---
PROJECT_NAME="jor-conn"
VERSION=$(grep -m 1 "Version:" "src/DEBIAN/control" | awk '{print $2}')
BUILD_DIR="build"
PACKAGE_NAME="${PROJECT_NAME}_${VERSION}_all"

echo -e "${COLOR_YELLOW}Building ${PROJECT_NAME} v${VERSION}...${COLOR_RESET}"

# --- Clean up previous build ---
echo "1. Cleaning up previous build..."
rm -rf "${BUILD_DIR}"
rm -f "${PROJECT_NAME}"_*.deb

# --- Create build structure ---
echo "2. Creating build directory structure..."
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/DEBIAN"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/usr/local/bin"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/usr/local/lib/${PROJECT_NAME}"
mkdir -p "${BUILD_DIR}/${PACKAGE_NAME}/etc/${PROJECT_NAME}/networks"

# --- Copy source files ---
echo "3. Copying source files..."
cp -r src/DEBIAN/* "${BUILD_DIR}/${PACKAGE_NAME}/DEBIAN/"
cp -r src/usr/local/bin/* "${BUILD_DIR}/${PACKAGE_NAME}/usr/local/bin/"
cp -r src/usr/local/lib/jor-conn/* "${BUILD_DIR}/${PACKAGE_NAME}/usr/local/lib/${PROJECT_NAME}/"
cp -r src/etc/jor-conn/* "${BUILD_DIR}/${PACKAGE_NAME}/etc/${PROJECT_NAME}/"

# --- Set permissions ---
echo "4. Setting file permissions..."
chmod +x "${BUILD_DIR}/${PACKAGE_NAME}/DEBIAN/preinst"
chmod +x "${BUILD_DIR}/${PACKAGE_NAME}/DEBIAN/postinst"
chmod +x "${BUILD_DIR}/${PACKAGE_NAME}/usr/local/bin/"*

# --- Build the Debian package ---
echo "5. Building the Debian package..."
dpkg-deb --build "${BUILD_DIR}/${PACKAGE_NAME}"

# --- Move Package ---
echo "6. Moving package to project root..."
mv "${BUILD_DIR}/${PACKAGE_NAME}.deb" .

# --- Final Message ---
echo -e "${COLOR_GREEN}"
echo "================================================================"
echo "✅ BUILD COMPLETE!"
echo ""
echo -e "   Package created: ${COLOR_BOLD}${PACKAGE_NAME}.deb${COLOR_RESET}"
echo -e "   To install, run:"
echo -e "     ${COLOR_CYAN}sudo dpkg -i ${PACKAGE_NAME}.deb${COLOR_RESET}"
echo ""
echo -e "   After installation, be sure to:"
echo -e "   1. Edit ${COLOR_BOLD}/etc/jor-conn/config.conf${COLOR_RESET} to match your setup."
echo -e "   2. Customize network profiles in ${COLOR_BOLD}/etc/jor-conn/networks/${COLOR_RESET}"
echo "================================================================"
echo -e "${COLOR_RESET}"

# --- Cleanup ---
echo "7. Cleaning up build directory..."
rm -rf "${BUILD_DIR}"
echo "Done."