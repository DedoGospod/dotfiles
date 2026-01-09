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
log_task() { echo -ne "${GREEN}[INFO]${NC} $1... "; }

# System Scripts
SYSTEM_SRC=/home/dylan/dotfiles/scripts/system-scripts

if [ -d "$SYSTEM_SRC" ]; then
    log "Syncing system scripts..."

    # Define the files to sync ( Format: "source_relative_to_SYSTEM_SRC|target_absolute_path")
    SYSTEM_FILES=(
        "etc/cron.weekly/btrfs-clean-job|/etc/cron.weekly/btrfs-clean-job"
        "etc/cron.weekly/clean-pkg-managers|/etc/cron.weekly/clean-pkg-managers"
        "usr/local/bin/reboot-to-windows|/usr/local/bin/reboot-to-windows"
    )

    for entry in "${SYSTEM_FILES[@]}"; do
        src="${entry%%|*}"
        target="${entry##*|}"
        full_src="$SYSTEM_SRC/$src"

        if [ -f "$full_src" ]; then
            log_task "Installing $target"
            sudo install -Dm 755 "$full_src" "$target" && echo -e "${GREEN}Done.${NC}" || echo -e "${RED}Failed.${NC}"
        else
            warn "Source file not found: $src"
        fi
    done
else
    warn "System scripts directory not found at $SYSTEM_SRC."
fi
