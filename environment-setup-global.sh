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

# Check if running as root (Don't do this!)
if [ "$EUID" -eq 0 ]; then
    error "Please do not run this script as root."
    error "Run it as a normal user. You will be prompted for sudo password when needed."
    exit 1
fi

# Ask for sudo upfront to prevent timeouts later
sudo -v

# This runs in the background for the duration of the script.
keep_sudo_alive() {
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done
}

log "Requesting sudo privileges upfront..."
keep_sudo_alive &
SUDO_PID=$!

# Ensure the background process dies when the script exits
trap 'kill $SUDO_PID' EXIT

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
    zsh tmux wayland-pipewire-idle-inhibit kwalletrc theme uwsm-autostart mangohud
    arch-config
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

# Shell
if command -v zsh >/dev/null 2>&1 && [[ "$SHELL" != *"zsh"* ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(command -v zsh)"
fi

# Timeshift Autosnap Config
TS_CONFIG="/etc/timeshift-autosnap.conf"
if [ -f "$TS_CONFIG" ]; then
    if ! grep -q "^maxSnapshots=1$" "$TS_CONFIG"; then
        log "Configuring Timeshift maxSnapshots to 1..."
        sudo sed -i 's/^maxSnapshots=.*/maxSnapshots=1/' "$TS_CONFIG"
    else
        log "Timeshift maxSnapshots is already set to 1."
    fi
else
    warn "Timeshift config not found at $TS_CONFIG. Skipping."
fi

# Tmux Plugin Manager
if command -v tmux >/dev/null 2>&1; then
    TPM_PATH="${TPM_PATH:-$HOME/.tmux/plugins/tpm}"

    if [ ! -d "$TPM_PATH" ]; then
        log "Tmux found. Installing Tmux Plugin Manager..."
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_PATH"
    else
        log "TPM already installed."
    fi
else
    warn "Tmux is not installed. Skipping TPM setup."
fi

# Ask to setup nvidia
read -r -p "Setup NVIDIA? (y/N): " setup_nvidia

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

# Enable NVIDIA KMS
if [[ "$setup_nvidia" =~ ^[Yy]$ ]]; then
    CONF_FILE="/etc/modprobe.d/nvidia.conf"
    SETTING="options nvidia-drm modeset=1"

    if [ ! -f "$CONF_FILE" ] || ! grep -Fxq "$SETTING" "$CONF_FILE"; then
        log "Enabling NVIDIA Kernel Mode Setting (KMS)..."
        echo "$SETTING" | sudo tee "$CONF_FILE" >/dev/null
    else
        log "NVIDIA KMS already configured."
    fi
fi

# Inject NVIDIA modules into mkinitcpio for initramfs regeneration
if [[ "$setup_nvidia" =~ ^[Yy]$ ]]; then
    MK_CONF="/etc/mkinitcpio.conf"

    # Check if nvidia_drm is already in the MODULES array (even if commented out)
    if ! grep -E "^MODULES=.*nvidia_drm" "$MK_CONF" >/dev/null 2>&1 &&
        ! grep -E "^MODULES\+=\(.*\bnvidia_drm\b.*\)" "$MK_CONF" >/dev/null 2>&1; then

        # Append the new modules line
        log "Injecting NVIDIA modules into mkinitcpio..."
        echo -e "\n# Added by setup script\nMODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee -a "$MK_CONF" >/dev/null

        log "Regenerating initramfs (this may take a moment)..."
        sudo mkinitcpio -P
    else
        log "NVIDIA modules already present in mkinitcpio. Skipping regeneration."
    fi
fi

# NVIDIA uwsm env variables
if [[ "$setup_nvidia" =~ ^[Yy]$ ]]; then
    log "Creating UWSM environment configuration for NVIDIA..."
    cat <<EOF >"$HOME/.config/uwsm/env-nvidia"
export LIBVA_DRIVER_NAME=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export NVD_BACKEND=direct
export ELECTRON_OZONE_PLATFORM_HINT=auto
EOF

    if ! grep -q "env-nvidia" "$HOME/.config/uwsm/env" 2>/dev/null; then
        echo "export-include env-nvidia" >>"$HOME/.config/uwsm/env"
    fi
fi
