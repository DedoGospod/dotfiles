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
header()  { echo -e "\n${BLUE}==== $1 ====${NC}"; }
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

log_task() { echo -ne "${GREEN}[INFO]${NC} $1... "; }
ok()       { echo -e "${GREEN}Done.${NC}"; }
fail()     { echo -e "${RED}Failed.${NC}"; }

# Check if running as root (Don't do this!)
if [ "$EUID" -eq 0 ]; then
    error "Please do not run this script as root."
    error "Run it as a normal user. You will be prompted for sudo password when needed."
    exit 1
fi

# Ask for sudo upfront to prevent timeouts later
sudo -v

# Optional setups
echo ""
header "CONFIGURATION QUESTIONS"
read -r -p "$(echo -e "  ${YELLOW}??${NC} Setup NVIDIA drivers? (y/N): ")" setup_nvidia
read -r -p "$(echo -e "  ${YELLOW}??${NC} Setup WakeOnLan? (y/N): ")" setup_wakeonlan
read -r -p "$(echo -e "  ${YELLOW}??${NC} Setup system for gaming? (y/N): ")" setup_gaming
read -r -p "$(echo -e "  ${YELLOW}??${NC} Do you want to stow your dotfiles with GNU STOW? [y/N]: ")" stow_dotfiles
echo ""

# Rustup
if ! command -v rustup &>/dev/null; then
    log_task "Installing rustup"
    if sudo pacman -S --noconfirm rustup > /dev/null 2>&1 && rustup default stable > /dev/null 2>&1; then ok; else fail; fi
else
    log "Rustup already installed."
fi

# Paru
if ! command -v paru &>/dev/null; then
    log_task "Installing Paru"
    if sudo pacman -S --needed --noconfirm base-devel git > /dev/null 2>&1 && \
       git clone https://aur.archlinux.org/paru.git /tmp/paru > /dev/null 2>&1 && \
       (cd /tmp/paru && makepkg -si --noconfirm > /dev/null 2>&1) && \
       rm -rf /tmp/paru; then ok; else fail; fi
else
    log "Paru already installed."
fi

# Set XDG paths and application specific paths
header "ENVIRONMENT SETUP"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

log_task "Creating directory structure"
if mkdir -p \
    "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" \
    "${XDG_STATE_HOME}/zsh" "${XDG_CACHE_HOME}/zsh" \
    "${XDG_DATA_HOME}/gnupg" "${XDG_STATE_HOME}/python"; then ok; else fail; fi


# Stow Packages (Directories in your dotfiles folder)
STOW_FOLDERS=(
    hypr backgrounds fastfetch kitty mpv nvim starship swaync waybar wofi yazi
    zsh tmux wayland-pipewire-idle-inhibit kwalletrc theme uwsm-autostart arch-config
)

# Dotfiles
DOTFILES_DIR="$HOME/dotfiles"
if [[ "$stow_dotfiles" =~ ^[Yy]$ ]]; then
    if [ -d "$DOTFILES_DIR" ]; then
        log "Stowing dotfiles..."
        cd "$DOTFILES_DIR"

        if [ -d "systemd-user" ]; then
            log_task "Stowing systemd-user"
            if stow -t "$HOME" --restow --no-folding systemd-user; then ok; else fail; fi
        fi

        if [ -d "scripts/user-scripts" ]; then
            log_task "Stowing user scripts"
            if stow -d "scripts" -t "$HOME" --restow user-scripts; then ok; else fail; fi
        fi

        for folder in "${STOW_FOLDERS[@]}"; do
            if [ -d "$folder" ]; then
                log_task "Stowing $folder"
                if stow -t "$HOME" --restow "$folder"; then ok; else fail; fi
            else
                warn "Skipping $folder (not found)."
            fi
        done
        cd - >/dev/null
    fi
fi


# System Scripts
SYSTEM_SRC="$DOTFILES_DIR/scripts/system-scripts"
if [ -d "$SYSTEM_SRC" ]; then
    log "Syncing system scripts..."
    SYSTEM_FILES=(
        "etc/cron.weekly/btrfs-clean-job|/etc/cron.weekly/btrfs-clean-job"
        "etc/cron.weekly/clean-pkg-managers|/etc/cron.weekly/clean-pkg-managers"
        "usr/local/bin/reboot-to-windows|/usr/local/bin/reboot-to-windows"
    )
    for entry in "${SYSTEM_FILES[@]}"; do
        src="${entry%%|*}"
        target="${entry##*|}"
        if [ -f "$SYSTEM_SRC/$src" ]; then
            log_task "Installing $target"
            if sudo install -Dm 755 "$SYSTEM_SRC/$src" "$target"; then ok; else fail; fi
        fi
    done
fi

# Gamescope Cap
if command -v gamescope >/dev/null 2>&1; then
    GAMESCOPE_PATH=$(command -v gamescope)

    # Check if the capability is already present
    if ! getcap "$GAMESCOPE_PATH" | grep -q "cap_sys_nice+ep"; then
        log_task "Setting CAP_SYS_NICE for Gamescope"
        if sudo setcap 'cap_sys_nice=+ep' "$GAMESCOPE_PATH"; then ok; else fail; fi
    fi
else
    warn "Gamescope not found. Skipping capability setup."
fi

# Gamemode setup
if command -v gamemoded >/dev/null 2>&1; then
    if ! id -nG "$USER" | grep -qw "gamemode"; then
        log_task "Adding user to gamemode group"
        if sudo usermod -aG gamemode "$USER"; then ok; else fail; fi
        log "NOTE: You may need to log out and back in for group changes to apply."
    fi
else
    warn "'gamemoded' command not found. Skipping user group modification."
fi

header "SYSTEM CONFIGURATION"

# Shell
if command -v zsh >/dev/null 2>&1; then
    log_task "Changing shell to zsh"
    if chsh -s "$(command -v zsh)" "$USER"; then ok; else fail; fi
fi

# Timeshift Autosnap Config
TS_CONFIG="/etc/timeshift-autosnap.conf"
if [ -f "$TS_CONFIG" ]; then
    if ! grep -q "^maxSnapshots=1$" "$TS_CONFIG"; then
        log_task "Configuring Timeshift maxSnapshots"
        if sudo sed -i 's/^maxSnapshots=.*/maxSnapshots=1/' "$TS_CONFIG"; then ok; else fail; fi
    else
        log "Timeshift maxSnapshots is already set to 1."
    fi
else
    warn "Timeshift config not found at $TS_CONFIG. Skipping."
fi

# Tmux Plugin Manager
TPM_PATH="$HOME/.tmux/plugins/tpm"
if command -v tmux >/dev/null 2>&1; then
    TPM_PATH="${TPM_PATH:-$HOME/.tmux/plugins/tpm}"

    if [ ! -d "$TPM_PATH" ]; then
        log_task "Installing TPM"
        if git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_PATH"; then ok; else fail; fi
    else
        log "TPM already installed."
    fi
else
    warn "Tmux is not installed. Skipping TPM setup."
fi

# Create UWSM directory if it doesnt already exist
if command -v uwsm >/dev/null 2>&1; then
    log_task "UWSM found. Preparing configuration directory..."
    if mkdir -p "$HOME/.config/uwsm"; then ok; else fail; fi
else
    warn "UWSM not detected. Skipping uwsm directory configuration ..."

fi

# Hyprland-specific uwsm environment file
if command -v uwsm >/dev/null 2>&1; then
    log_task "Writing uwsm env-hyprland"
    if cat <<EOF >"$HOME/.config/uwsm/env-hyprland"
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
    then ok; else fail; fi

    if ! grep -q "env-hyprland" "$HOME/.config/uwsm/env" 2>/dev/null; then
        echo "export-include env-hyprland" >>"$HOME/.config/uwsm/env"
    fi
fi

# Enable NVIDIA KMS
if [[ "$setup_nvidia" =~ ^[Yy]$ ]]; then
    CONF_FILE="/etc/modprobe.d/nvidia.conf"
    SETTING="options nvidia-drm modeset=1"

    if [ ! -f "$CONF_FILE" ] || ! grep -Fxq "$SETTING" "$CONF_FILE"; then
        log_task "Enabling NVIDIA Kernel Mode Setting (KMS)..."
        if echo "$SETTING" | sudo tee "$CONF_FILE" >/dev/null; then ok; else fail; fi
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
        log_task "Injecting NVIDIA modules into mkinitcpio"
        if echo -e "\n# Added by setup script\nMODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee -a "$MK_CONF" >/dev/null; then ok; else fail; fi

        log_task "Regenerating initramfs (this may take a moment)..."
        if sudo mkinitcpio -P; then ok; else fail; fi
    else
        log "NVIDIA modules already present in mkinitcpio. Skipping regeneration."
    fi
fi

# NVIDIA uwsm env variables
if [[ "$setup_nvidia" =~ ^[Yy]$ ]]; then
    log_task "Creating UWSM NVIDIA env"
    if cat <<EOF >"$HOME/.config/uwsm/env-nvidia"
export LIBVA_DRIVER_NAME=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export NVD_BACKEND=direct
export ELECTRON_OZONE_PLATFORM_HINT=auto
EOF
    then ok; else fail; fi

    if ! grep -q "env-nvidia" "$HOME/.config/uwsm/env" 2>/dev/null; then
        echo "export-include env-nvidia" >>"$HOME/.config/uwsm/env"
    fi
fi

# WoL setup
if [[ "$setup_wakeonlan" =~ ^[Yy]$ ]]; then
    # Only detect the interface if we actually need it
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

    # Check if detection worked
    if [ -z "$INTERFACE" ]; then
        error "Could not detect a network interface. WoL service not created."
    else
        # We use log here because this is information, not the task yet
        log "Detected interface: $INTERFACE"
        SERVICE_FILE="/etc/systemd/system/wol.service"

        # This is the actual task
        log_task "Enabling WoL service for $INTERFACE"
        if cat <<EOF | sudo tee $SERVICE_FILE >/dev/null
[Unit]
Description=Enable Wake On LAN for $INTERFACE
After=network-online.target
Requires=network-online.target 

[Service]
Type=oneshot
ExecStart=/usr/bin/ethtool -s $INTERFACE wol g

[Install]
WantedBy=multi-user.target
EOF
        then ok; else fail; fi
    fi
fi

# NTSYNC (Kernel Module)
if [[ "$setup_gaming" =~ ^[Yy]$ ]]; then
    log_task "Enabling NTSYNC"
    if echo "ntsync" | sudo tee /etc/modules-load.d/ntsync.conf > /dev/null; then ok; else fail; fi
else
    warn "NTSYNC skipped. Windows games (Wine/Proton) may lack kernel-level sync support."
fi
