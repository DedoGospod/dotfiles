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

run_task() {
    local desc="$1"
    local cmd="$2"

    log_task "$desc"

    if eval "$cmd" >/dev/null 2>&1; then
        ok
        return 0
    else
        fail
        return 1
    fi
}

header "Btrfs setup"

# Neesed packages
PACMAN_PACKAGES+=(grub-btrfs inotify-tools btrfsmaintenance snapper snap-pac)

# Install Packages
log_task "Installing Official Packages..."
sudo pacman -S --needed --noconfirm -q "${PACMAN_PACKAGES[@]}" &>/dev/null
ok

# List of Btrfs units to enable
btrfs_units=(
    "grub-btrfsd.service"
    "snapper-timeline.timer"
    "snapper-cleanup.timer"
    "btrfs-scrub.timer"
    "btrfs-balance.timer"
)

# Enable btrfs related services
for unit in "${btrfs_units[@]}"; do
    # Check if the unit is already enabled
    if systemctl is-enabled --quiet "$unit" 2>/dev/null; then
        log_task "$unit is already enabled"
        ok
    else
        run_task "Enabling $unit" "sudo systemctl enable --now $unit"
    fi
done
