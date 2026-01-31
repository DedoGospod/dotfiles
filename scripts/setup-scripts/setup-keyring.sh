#!/usr/bin/env bash

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper Functions
header()  { echo -e "\n${BLUE}==== $1 ====${NC}"; }
log()     { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

log_task() { echo -ne "${GREEN}[INFO]${NC} $1... "; }
ok()       { echo -e "${GREEN}Done.${NC}"; }
fail()     { echo -e "${RED}Failed.${NC}"; }

# Ensure systemctl is available
if ! command -v systemctl >/dev/null 2>&1; then
    error "systemctl not found. This script requires a systemd-based distribution."
    exit 1
fi

# Mask KWallet
log_task "Masking kwallet"
systemctl --user mask --now kwalletd5.service
systemctl --user mask --now kwalletd6.service
ok

# Mask Gnome-Keyring
log_task "Masking gnome keyring"
systemctl --user mask --now gnome-keyring-daemon.service
ok

# Start ssh agent
log_task "Staring ssh agent"
systemctl --user enable --now ssh-agent.socket
ok
