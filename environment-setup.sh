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

# This ensures that when the script exits, the background sudo loop is killed immediately
trap 'kill $(jobs -p) 2>/dev/null' EXIT

# Ask for sudo upfront to prevent timeouts later
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# --- XDG DIRECTORY SETUP ---
header "XDG DIRECTORY SETUP"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

log_task "Creating directory structure"
if mkdir -p \
    "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" \
    "${XDG_STATE_HOME}/zsh" "${XDG_CACHE_HOME}/zsh" \
    "${XDG_DATA_HOME}/gnupg" "${XDG_STATE_HOME}/python"; then ok; else fail; fi

# Define scripts directory
SCRIPT_DIR="$HOME/dotfiles/scripts/setup-scripts/"

header "SYSTEM PREPARATION"

# Ensure all setup scripts are executable
if [ -d "$SCRIPT_DIR" ]; then
    chmod u+x "$SCRIPT_DIR"/*.sh 2>/dev/null
    log_task "Permissions updated for setup scripts"
    ok
else
    fail
    error "Directory $SCRIPT_DIR not found!"
    exit 1
fi

# IMPORT the package list
PACKAGE_LIST="$SCRIPT_DIR/package-lists"
if [[ -f "$PACKAGE_LIST" ]]; then
    # shellcheck source=/dev/null
    source "$PACKAGE_LIST"
    log_task "Package lists loaded."
    ok
else
    fail
    error "package-list.sh not found!"
    exit 1
fi

# --- USER INTERACTION ---
header "CONFIGURATION QUESTIONS"

# Interaction Helper
ask() {
    read -r -p "$(echo -e "  ${YELLOW}??${NC} $1 (y/N): ")" response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Core Setup Choices
ask "Set up dotfiles with GNU Stow?" && stow_dotfiles="y"
ask "Install NVIDIA drivers?" && install_nvidia="y"
ask "Install Neovim dev tools?" && PACMAN_PACKAGES+=("${NEOVIM_DEPS[@]}")
ask "Setup ufw firewall?" && install_firewall="y"
ask "Setup virtualization?" && setup_virt="y"
ask "Setup wakeonlan?" && setup_wol="y"

# Conditional Gaming Group
if ask "Install gaming packages?"; then
    install_gaming="y"
    if ask "Install OBS and game recording tools?"; then
        AUR_PACKAGES+=("obs-studio" "obs-vkcapture")
    fi
fi

echo ""

# --- INSTALLATION PHASE ---

# Import install phase file
INSTALL_PHASE="$SCRIPT_DIR/install-phase"

if [[ -f "$INSTALL_PHASE" ]]; then
    # shellcheck source=/dev/null
    source "$INSTALL_PHASE"
else
    error "install-phase script not found at $INSTALL_PHASE"
    exit 1
fi

# Setup script function
run_setup_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"

    if [[ -f "$script_path" ]]; then
        bash "$script_path"
    else
        error "Could not find $script_name"
    fi
}

# Mandatory Setup
run_setup_script "setup-user-env.sh"
run_setup_script "setup-theme.sh"

# Conditional Setups
[[ "$stow_dotfiles" =~ ^[Yy]$ ]] && run_setup_script "setup-dotfiles.sh"
[[ "$install_nvidia" =~ ^[Yy]$ ]] && run_setup_script "setup-nvidia.sh"
[[ "$install_gaming" =~ ^[Yy]$ ]] && run_setup_script "setup-gaming.sh"
[[ "$install_firewall" =~ ^[Yy]$ ]] && run_setup_script "setup-firewall.sh"
[[ "$setup_virt" =~ ^[Yy]$ ]] && run_setup_script "setup-virtualization.sh"
[[ "$setup_wol" =~ ^[Yy]$ ]] && run_setup_script "setup-wol.sh"

# --- FINISH ---
echo ""
echo "------------------------------------------------------"
log "Installation Complete! 🎉"
echo "------------------------------------------------------"

# Check if reboot is required
if [ -f /tmp/reboot_required ]; then
    rm /tmp/reboot_required

    if ask "System changes detected. Reboot now?"; then
        log "Rebooting..."
        sudo reboot
    else
        warn "Please reboot manually to apply changes."
    fi
else
    success "No system changes required a reboot. Enjoy!"
fi
