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

# Create UWSM directory if it doesnt already exist
if command -v uwsm >/dev/null 2>&1; then
    log "UWSM found. Preparing configuration directory..."
    mkdir -p "$HOME/.config/uwsm"
else
    warn "UWSM not detected. Skipping uwsm directory configuration ..."

fi

# Create/Overwrite the Hyprland-specific uwsm environment file
if command -v uwsm >/dev/null 2>&1; then
    cat <<EOF >"$HOME/.config/uwsm/env-hyprland"
# Session Identity
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland

# Toolkit Backends
export GDK_BACKEND=wayland,x11
export QT_QPA_PLATFORM="wayland;xcb"
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland

# Theming
export QT_QPA_PLATFORMTHEME=qt6ct
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
EOF

    # Ensure the main env file includes our new hyprland env
    if ! grep -q "env-hyprland" "$HOME/.config/uwsm/env" 2>/dev/null; then
        echo "export-include env-hyprland" >>"$HOME/.config/uwsm/env"
    fi
fi
