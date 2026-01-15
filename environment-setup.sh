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

# Check if running as root (Don't do this!)
if [ "$EUID" -eq 0 ]; then
    error "Please do not run this script as root."
    error "Run it as a normal user. You will be prompted for sudo password when needed."
    exit 1
fi

# Ask for sudo upfront to prevent timeouts later
sudo -v

# --- ENVIRONMENT SETUP ---
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

# Define the directory and script list
SCRIPT_DIR="$HOME/dotfiles/scripts/setup"
PACKAGE_LIST="$SCRIPT_DIR/fresh-install/package-lists.sh"
SCRIPTS=(
    "setup-dotfiles.sh"
    "setup-nvidia.sh"
    "setup-gaming.sh"
    "setup-firewall.sh"
    "setup-virtualization.sh"
    "setup-wol.sh"
)

# Ensure all scripts are executable
if [ -d "$SCRIPT_DIR" ]; then
    cd "$SCRIPT_DIR" || exit
    chmod u+x "${SCRIPTS[@]}" 2>/dev/null
    log_task "Permissions updated for setup scripts."
    ok
else
    error "Directory $SCRIPT_DIR not found!"
fi


# IMPORT the package list
if [[ -f "$PACKAGE_LIST" ]]; then
    # shellcheck source=/dev/null
    source "$PACKAGE_LIST"
    log_task "Package lists loaded."
    ok
else
    error "package-list.sh not found!"
    exit 1
fi

# Interaction Helper
ask() {
    read -r -p "$(echo -e "  ${YELLOW}??${NC} $1 (y/N): ")" response
    [[ "$response" =~ ^[Yy]$ ]]
}

# --- USER INTERACTION ---
header "CONFIGURATION QUESTIONS"

# Core Setup Choices
ask "Set up dotfiles with GNU Stow?" && stow_dotfiles="y"
ask "Install NVIDIA drivers?"       && install_nvidia="y"
ask "Install Neovim dev tools?"     && PACMAN_PACKAGES+=("${NEOVIM_DEPS[@]}")
ask "Setup ufw firewall?"           && install_firewall="y"
ask "Setup virtualization?"         && setup_virt="y"
ask "Setup wakeonlan?"              && setup_wol="y"

# Conditional Gaming Group
if ask "Install gaming packages?"; then
    install_gaming="y"
    if ask "Install OBS and game recording tools?"; then
        AUR_PACKAGES+=("obs-studio" "obs-vkcapture")
    fi
fi

echo ""

# Check for btrfs root
log_task "Checking filesystem type"
if [[ $(findmnt -n -o FSTYPE --target /) == "btrfs" ]]; then
    ok
    log "Btrfs root detected. Adding maintenance packages."
    PACMAN_PACKAGES+=(grub-btrfs inotify-tools btrfsmaintenance snapper snap-pac)
else
    ok
    log "Root is not Btrfs. Skipping Btrfs-specific tools."
fi

# --- INSTALLATION PHASE ---
header "INSTALLATION PHASE"

# Update system
log_task "Updating system"
if sudo pacman -Syu --noconfirm >/dev/null 2>&1; then ok; else fail; fi

# Install rustup
if ! command -v rustup &>/dev/null; then
    log_task "Installing rustup"
    if sudo pacman -S --noconfirm rustup >/dev/null 2>&1 && rustup default stable >/dev/null 2>&1; then ok; else fail; fi
else
    log_task "Rustup already installed."
    ok
fi

# Install Paru
if ! command -v paru &>/dev/null; then
    log_task "Installing Paru"
    if sudo pacman -S --needed --noconfirm base-devel git >/dev/null 2>&1 &&
        git clone https://aur.archlinux.org/paru.git /tmp/paru >/dev/null 2>&1 &&
        (cd /tmp/paru && makepkg -si --noconfirm >/dev/null 2>&1) &&
        rm -rf /tmp/paru; then ok; else fail; fi
else
    log_task "Paru already installed."
    ok
fi

# Install pacman pkgs
log_task "Installing Official Packages..."
sudo pacman -S --needed --noconfirm -q "${PACMAN_PACKAGES[@]}" &>/dev/null
ok

# Install AUR packages
log_task "Installing AUR Packages..."
paru -S --needed --noconfirm -q "${AUR_PACKAGES[@]}" &>/dev/null
ok

# Install Flatpaks
log_task "Installing Flatpak Apps..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive --or-update flathub "${FLATPAK_APPS[@]}" &>/dev/null
ok

# System configuration
header "SYSTEM CONFIGURATION"

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



# Dotfile setup
if [[ "$stow_dotfiles" =~ ^[Yy]$ ]]; then
    DOTFILE_SCRIPT="$SCRIPT_DIR/setup-dotfiles.sh"

    if [ -f "$DOTFILE_SCRIPT" ]; then
        bash "$DOTFILE_SCRIPT"
    else
        warn "Could not find $DOTFILE_SCRIPT"
    fi
fi

# Nvidia setup
if [[ "$install_nvidia" =~ ^[Yy]$ ]]; then
    NVIDIA_SCRIPT="$SCRIPT_DIR/setup-nvidia.sh"

    if [ -f "$NVIDIA_SCRIPT" ]; then
        bash "$NVIDIA_SCRIPT"
    else
        warn "Could not find $NVIDIA_SCRIPT"
    fi
fi

# Gaming setup
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    GAMING_SCRIPT="$SCRIPT_DIR/setup-gaming.sh"

    if [ -f "$GAMING_SCRIPT" ]; then
        bash "$GAMING_SCRIPT"
    else
        warn "Could not find $GAMING_SCRIPT"
    fi
fi

# Firewall setup
if [[ "$install_firewall" =~ ^[Yy]$ ]]; then
    FIREWALL_SCRIPT="$SCRIPT_DIR/setup-firewall.sh"

    if [ -f "$FIREWALL_SCRIPT" ]; then
        bash "$FIREWALL_SCRIPT"
    else
        warn "Could not find $FIREWALL_SCRIPT"
    fi
fi

# Virtualization setup
if [[ "$setup_virt" =~ ^[Yy]$ ]]; then
    VIRT_SCRIPT="$SCRIPT_DIR/setup-virtualization.sh"

    if [ -f "$VIRT_SCRIPT" ]; then
        bash "$VIRT_SCRIPT"
    else
        warn "Could not find $VIRT_SCRIPT"
    fi
fi

# WakeOnLan setup
if [[ "$setup_wol" =~ ^[Yy]$ ]]; then
    WOL_SCRIPT="$SCRIPT_DIR/setup-wol.sh"

    if [ -f "$WOL_SCRIPT" ]; then
        bash "$WOL_SCRIPT"
    else
        warn "Could not find $WOL_SCRIPT"
    fi
fi

# --- FINISH ---
echo ""
echo "------------------------------------------------------"
log "Installation Complete! 🎉"
echo "------------------------------------------------------"

read -r -p "Would you like to reboot now? (Y/n): " reboot_now
if [[ "$reboot_now" =~ ^[Yy]$ || -z "$reboot_now" ]]; then
    log "Rebooting..."
    sudo reboot
else
    log "Please reboot manually to apply all changes."
fi
