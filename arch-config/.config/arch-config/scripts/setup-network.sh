#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Helper Functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

## WoL setup
# Only detect the interface if we actually need it
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

# Check if detection worked
if [ -z "$INTERFACE" ]; then
    error "Could not detect a network interface. WoL service not created."
else
    log "Detected interface: $INTERFACE"
    SERVICE_FILE="/etc/systemd/system/wol.service"

    # Create the service file
    cat <<EOF | sudo tee $SERVICE_FILE >/dev/null
[Unit]
Description=Enable Wake On LAN for $INTERFACE
After=network-online.target
Requires=network-online.target 

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s $INTERFACE wol g

[Install]
WantedBy=multi-user.target
EOF

    log "WoL service integrated with $INTERFACE."
fi
