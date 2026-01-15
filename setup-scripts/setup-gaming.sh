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

# Gaming settings
header "GAMING CONFIGURATION"

# Gamescope Cap
if command -v gamescope >/dev/null 2>&1; then
    GAMESCOPE_PATH=$(realpath "$(command -v gamescope)")

    # Check silently if the capability is missing
    if ! getcap "$GAMESCOPE_PATH" | grep -q "cap_sys_nice+ep"; then
        if sudo setcap 'cap_sys_nice=ep' "$GAMESCOPE_PATH"; then
            log_task "CAP_SYS_NICE is already set"
            ok
        else
            fail
        fi
    fi
else
    warn "Gamescope not found. Skipping capability setup."
fi

# Gamemode setup
if command -v gamemoded >/dev/null 2>&1; then
    if ! id -nG "$USER" | grep -qw "gamemode"; then
        log_task "Adding user to gamemode group"
        if sudo usermod -aG gamemode "$USER"; then ok; else fail; fi
        warn "NOTE: You may need to log out and back in for group changes to apply."
    else
        log_task "User already in gamemode group."
        ok
    fi
else
    warn "'gamemoded' command not found. Skipping user group modification."
fi

# NTSYNC (Kernel Module)
if grep -q "ntsync" /etc/modules-load.d/ntsync.conf 2>/dev/null; then
    log_task "NTSYNC already enabled"
    ok
else
    log_task "Enabling NTSYNC"
    if echo "ntsync" | sudo tee /etc/modules-load.d/ntsync.conf >/dev/null; then
        ok
    else
        warn "NTSYNC skipped. Windows games (Wine/Proton) may lack kernel-level sync support."
    fi
fi
