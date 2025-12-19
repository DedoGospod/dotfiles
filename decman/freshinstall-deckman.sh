#!/bin/bash

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

# Environment Setup
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

# Rustup
if ! command -v rustup &>/dev/null; then
    log "Installing rustup..."
    sudo pacman -S --noconfirm rustup
    rustup default stable
else
    log "Rustup is already installed."
fi

# Paru (AUR Helper)
if ! command -v paru &>/dev/null; then
    log "Installing Paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
else
    log "Paru is already installed."
fi

# Install flatpak
log "Installing Flatpak"
sudo pacman -S --needed --noconfirm flatpak
log "Installing Flathub Repo..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installing decman
log "Installing AUR Package 'decman' ..."
paru -S --needed --noconfirm decman

# Shell
log "Installing zsh shell"
sudo pacman -S --needed --noconfirm zsh
log "Setting zsh as default shell"
if [[ "$SHELL" != *"zsh"* ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

# Tmux Plugin Manager
if [ ! -d "$TPM_PATH" ]; then
    log "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
else
    log "TPM already installed."
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

# Run decman
sudo decman --source ~/dotfiles/decman/source.py
