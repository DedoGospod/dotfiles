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

# Setup WakeOnLan
    WOL_CONF="/etc/NetworkManager/conf.d/wol.conf"

    # Check if already set
    if [[ -f "$WOL_CONF" ]]; then
        log_task "Wake-on-LAN is already configured"
        ok
    else
        log_task "Configuring Global & Active Wake-on-LAN"

        WOL_CONF="/etc/NetworkManager/conf.d/wol.conf"
        UDEV_RULE="/etc/udev/rules.d/81-wol.rules"

        # Persistent global config
        sudo mkdir -p /etc/NetworkManager/conf.d
        echo -e "[connection]\nethernet.wake-on-lan=magic" | sudo tee "$WOL_CONF" >/dev/null

        # Hardware-Level udev rule
        echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="en*", RUN+="/usr/sbin/ethtool -s %k wol g"' | sudo tee "$UDEV_RULE" >/dev/null

        # Fix Existing Connections (Handles spaces in names)
        while IFS= read -r conn; do
            if [[ -n "$conn" ]]; then
                sudo nmcli connection modify "$conn" 802-3-ethernet.wake-on-lan magic 2>/dev/null
                sudo nmcli connection up "$conn" >/dev/null 2>&1
            fi
        done < <(nmcli -t -f NAME,TYPE connection show | grep ":802-3-ethernet" | cut -d: -f1)

        # Final reload
        if sudo systemctl reload NetworkManager 2>/dev/null; then
            ok
        else
            warn "NetworkManager reload skipped; settings will apply on boot."
            ok
        fi
    fi
