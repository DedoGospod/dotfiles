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

# Define all target MIMETYPES (Video + Image)
MEDIA_MIMETYPES=(
    "video/mp4" "video/x-matroska" "video/webm" "video/x-flv"
    "application/vnd.rn-realmedia" "video/quicktime" "video/x-msvideo"
    "audio/mp3" "audio/ogg" "audio/wav" "audio/flac"
)

IMAGE_MIMETYPES=(
    "image/jpeg" "image/png" "image/gif" "image/webp" 
    "image/bmp" "image/tiff" "image/svg+xml" "image/avif"
)

# Set MPV Defaults
if command -v mpv >/dev/null 2>&1; then
    log_task "Setting MPV as default for media..."
    for mime in "${MEDIA_MIMETYPES[@]}"; do
        xdg-mime default mpv.desktop "$mime"
    done
    ok
fi

# Set IMV Defaults
IMAGE_APP="imv.desktop"
if command -v imv >/dev/null 2>&1 || command -v imvr >/dev/null 2>&1; then
    
    # Detect if we should use imv.desktop or imvr.desktop
    if [ ! -f "/usr/share/applications/$IMAGE_APP" ]; then
        IMAGE_APP="imvr.desktop"
    fi

    log_task "Setting $IMAGE_APP as default for images..."
    for mime in "${IMAGE_MIMETYPES[@]}"; do
        xdg-mime default "$IMAGE_APP" "$mime"
    done
    ok
else
    echo -e "\e[31m[ERROR]\e[0m imv not found. Install it first."
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
