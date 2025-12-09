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

# Set XDG paths and application specific paths
log "Setting XDG environment variables..."
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

log "Creating directory structure..."
mkdir -p \
    "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" \
    "${XDG_STATE_HOME}/zsh" "${XDG_CACHE_HOME}/zsh" \
    "${XDG_DATA_HOME}/gnupg" "${XDG_STATE_HOME}/python"

# Stow Packages (Directories in your dotfiles folder)
STOW_FOLDERS=(
    hypr backgrounds fastfetch kitty mpv nvim starship swaync waybar wofi yazi
    zsh tmux wayland-pipewire-idle-inhibit kwalletrc theme uwsm-autostart
)

# Directory paths
DOTFILES_DIR="$HOME/dotfiles"
TPM_PATH="$HOME/.tmux/plugins/tpm"

# Dotfiles
if [ -d "$DOTFILES_DIR" ]; then
    log "Stowing dotfiles..."
    cd "$DOTFILES_DIR" || exit 1

    if [ -d "systemd-user" ]; then
        echo -n "Stowing systemd-user (no-folding)... "
        stow -t "$HOME" --restow --no-folding systemd-user 2>/dev/null && echo "Done." || echo "Failed."
    fi

    for folder in "${STOW_FOLDERS[@]}"; do
        if [ -d "$folder" ]; then
            echo -n "Stowing $folder... "
            stow -t "$HOME" --restow "$folder" 2>/dev/null && echo "Done." || echo "Failed."
        else
            warn "Skipping $folder (directory not found in $DOTFILES_DIR)."
        fi
    done

    cd - >/dev/null
else
    error "Dotfiles directory not found at $DOTFILES_DIR."
fi

# Gamescope Cap
if command -v gamescope &>/dev/null; then
    log "Setting CAP_SYS_NICE for Gamescope..."
    sudo setcap 'cap_sys_nice=+ep' "$(which gamescope)"
fi

# Gamemode setup
if command -v gamemoded &>/dev/null; then
    log "Adding user to gamemode group"
    sudo usermod -aG gamemode "$USER"
else
    log "'gamemoded' command not found. Skipping user group modification."
fi

# Shell
if [[ "$SHELL" != *"zsh"* ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

# Timeshift Autosnap Config
TS_CONFIG="/etc/timeshift-autosnap.conf"
if [ -f "$TS_CONFIG" ]; then
    log "Configuring Timeshift maxSnapshots..."
    sudo sed -i 's/^maxSnapshots=.*/maxSnapshots=1/' "$TS_CONFIG"
fi

# Tmux Plugin Manager
if [ ! -d "$TPM_PATH" ]; then
    log "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
else
    log "TPM already installed."
fi
