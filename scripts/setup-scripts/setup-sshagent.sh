#!/usr/bin/env bash

# Colors for logging
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Helper Functions
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_task() { echo -ne "${GREEN}[INFO]${NC} $1... "; }

# Ensure systemctl is available
if ! command -v systemctl >/dev/null 2>&1; then
    error "systemctl not found. This script requires a systemd-based distribution."
    exit 1
fi

# Start ssh agent
log_task "Staring ssh agent"
systemctl --user enable --now ssh-agent.socket
ok
