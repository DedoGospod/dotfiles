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

header "USER ENVIRONMENT CONFIGURATION"

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

ROOT_FS=$(findmnt -n -o FSTYPE --target /)
if [[ "$ROOT_FS" == "btrfs" ]]; then

    # List of Btrfs units to enable
    btrfs_units=(
        "grub-btrfsd.service"
        "snapper-timeline.timer"
        "snapper-cleanup.timer"
        "btrfs-scrub.timer"
        "btrfs-balance.timer"
    )

    for unit in "${btrfs_units[@]}"; do
        run_task "Enabling $unit" "sudo systemctl enable --now $unit"
    done

else
    echo -e "  [System] Root is not Btrfs ($ROOT_FS). Skipping Btrfs tasks."
fi

# Set mpv to default media player
MIMETYPES=(
    "video/mp4"
    "video/x-matroska"
    "video/webm"
    "video/x-flv"
    "application/vnd.rn-realmedia"
    "video/quicktime"
    "video/x-msvideo"
)

# Check if mpv is installed
if command -v mpv >/dev/null 2>&1; then
    log_task "Mpv is installed. Setting as default for video types..."
    ok

    # Loop through mimetypes and set mpv.desktop as default
    for mime in "${MIMETYPES[@]}"; do
        xdg-mime default mpv.desktop "$mime"
    done

else
    error "mpv is not installed. Please install it first."
fi

# Shell
if command -v zsh >/dev/null 2>&1; then
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
        log_task "Changing shell to zsh"
        if chsh -s "$(command -v zsh)" "$USER"; then ok; else fail; fi
    else
        log_task "Shell is already set to zsh"
        ok
    fi
fi

# Tmux Plugin Manager
TPM_PATH="$HOME/.tmux/plugins/tpm"
if command -v tmux >/dev/null 2>&1; then
    TPM_PATH="${TPM_PATH:-$HOME/.tmux/plugins/tpm}"

    if [ ! -d "$TPM_PATH" ]; then
        log_task "Installing TPM"
        if git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_PATH"; then ok; else fail; fi
    else
        log_task "TPM already installed."
        ok
    fi
else
    warn "Tmux is not installed. Skipping TPM setup."
fi
