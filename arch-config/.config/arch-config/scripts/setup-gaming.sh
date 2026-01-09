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

# Gamescope Cap
if command -v gamescope >/dev/null 2>&1; then
    GAMESCOPE_PATH=$(command -v gamescope)

    # Check if the capability is already present
    if ! getcap "$GAMESCOPE_PATH" | grep -q "cap_sys_nice+ep"; then
        log "Setting CAP_SYS_NICE for Gamescope..."
        sudo setcap 'cap_sys_nice=+ep' "$GAMESCOPE_PATH"
    fi
else
    warn "Gamescope not found. Skipping capability setup."
fi

# Gamemode setup
if command -v gamemoded >/dev/null 2>&1; then
    if ! id -nG "$USER" | grep -qw "gamemode"; then
        log "Adding user to gamemode group..."
        sudo usermod -aG gamemode "$USER"
        log "NOTE: You may need to log out and back in for group changes to apply."
    fi
else
    warn "'gamemoded' command not found. Skipping user group modification."
fi
