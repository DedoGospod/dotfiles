#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper Functions
header() { echo -e "\n${BLUE}==== $1 ====${NC}"; }
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

log_task() { echo -ne "${GREEN}[INFO]${NC} $1... "; }
ok() { echo -e "${GREEN}Done.${NC}"; }
fail() { echo -e "${RED}Failed.${NC}"; }

header "Wake-on-LAN Configuration"

# Install necessary tools
if ! command -v ethtool &> /dev/null; then
    sudo pacman -S --noconfirm ethtool > /dev/null 2>&1
    ok
else
    log_task "ethtool is already installed."
    ok
fi

# Identify the primary ethernet interface
INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo' | grep '^e' | head -n 1)

if [ -z "$INTERFACE" ]; then
    fail
    error "No ethernet interface found starting with 'e' (e.g., enp3s0)."
    exit 1
fi
log_task "Target interface identified: $INTERFACE"
ok

# Create the systemd template service
SERVICE_PATH="/etc/systemd/system/wol@.service"

log_task "Creating systemd service at $SERVICE_PATH"
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Wake-on-LAN for %i
Requires=network.target
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s %i wol g

[Install]
WantedBy=multi-user.target
EOF
ok

# Enable and start the service
log_task "Enabling and starting wol@$INTERFACE.service"
sudo systemctl daemon-reload
sudo systemctl enable --now "wol@$INTERFACE.service" > /dev/null 2>&1
ok

# Handle NetworkManager
if systemctl is-active --quiet NetworkManager; then
    log_task "NetworkManager detected. Configuring connection settings"
    UUID=$(nmcli -t -f UUID,DEVICE connection show --active | grep ":$INTERFACE$" | cut -d: -f1)
    
    if [ -n "$UUID" ]; then
        sudo nmcli connection modify "$UUID" 802-3-ethernet.wake-on-lan magic
        ok
    else
        fail
        warn "Could not find an active NM connection for $INTERFACE."
    fi
fi

echo ""

# Verification
WOL_STATUS=$(sudo ethtool "$INTERFACE" | grep "Wake-on" || true)
log "Current WoL Status for $INTERFACE:"
echo "$WOL_STATUS"
