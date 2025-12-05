#!/bin/bash
# Arch Linux Hyprland Setup Script
# Combined and Optimized

# --- PRELIMINARY SETUP & CONSTANTS ---

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\133[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
log "Requesting sudo privileges upfront..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- CONFIGURATION & PACKAGE LISTS ---

# Directories
DOTFILES_DIR="$HOME/dotfiles"
TPM_PATH="$HOME/.tmux/plugins/tpm"

# Base Pacman Packages
PACMAN_PACKAGES=(
    # Core Desktop
    hyprland hypridle hyprlock hyprpaper hyprshot hyprpolkitagent 
    hyprland-guiutils hyprutils uwsm waybar wofi swaync dbus wlsunset

    # Portals & Theming
    xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
    qt5-wayland qt6-wayland qt6ct gnome-themes-extra

    # Apps & Utils
    kitty neovim nautilus yazi mpv fastfetch btop gnome-disk-utility 
    obsidian pavucontrol gnome-keyring seahorse rsync keepassxc obs-studio

    # Shell & CLI
    zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions starship 
    fzf zoxide fd tmux stow bat eza ripgrep ncdu trash-cli man-db

    # Network & Services
    networkmanager bluez bluez-utils pipewire wireplumber tlp cronie

    # Maintenance
    reflector timeshift ffmpeg ffmpegthumbnailer

    # Containerization
    flatpak

    # Kernel & Headers
    linux-headers linux-zen linux-zen-headers

    # Fonts
    ttf-cascadia-code-nerd ttf-ubuntu-font-family ttf-font-awesome 
    ttf-dejavu ttf-liberation ttf-croscore noto-fonts noto-fonts-cjk noto-fonts-emoji
)

# Optional Groups
NVIDIA_PACKAGES=(libva-nvidia-driver nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland)
GAMING_PACKAGES=(gamemode gamescope mangohud)
NEOVIM_DEPS=(npm nodejs unzip clang go shellcheck zig luarocks dotnet-sdk cmake gcc imagemagick)
WAKEONLAN_PACKAGES=(wol ethtool)

# Flatpaks
FLATPAK_APPS=(
    it.mijorus.gearlever
    com.github.tchx84.Flatseal
    com.stremio.Stremio
    com.usebottles.bottles
    com.vysp3r.ProtonPlus
    io.github.ebonjaeger.bluejay
    com.github.wwmm.easyeffects
)

# AUR Packages
AUR_PACKAGES=(
    timeshift-autosnap
    wayland-pipewire-idle-inhibit
    brave-bin
    nvibrant-bin
    obs-vkcapture
    pyprland
)

# Stow Packages (Directories in your dotfiles folder)
STOW_FOLDERS=(
    hypr backgrounds fastfetch kitty mpv nvim starship swaync waybar wofi yazi 
    zshrc systemd-user tmux wayland-pipewire-idle-inhibit kwalletrc theme uwsm-autostart
)

# --- ENVIRONMENT SETUP ---

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

# --- USER INTERACTION ---

echo ""
log "--- Configuration Questions ---"
read -r -p "Install Gaming packages? (y/N): " install_gaming
read -r -p "Install NVIDIA drivers? (y/N): " install_nvidia
read -r -p "Install Neovim dev tools? (y/N): " install_neovim
read -r -p "Install WakeOnLan tools? (y/N): " install_wakeonlan
read -r -p "Set up dotfiles with GNU Stow? (y/N): " stow_dotfiles
echo ""

# Modify Package Lists based on answers
if [[ "$install_nvidia" =~ ^[Yy]$ ]]; then PACMAN_PACKAGES+=("${NVIDIA_PACKAGES[@]}"); fi
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then PACMAN_PACKAGES+=("${GAMING_PACKAGES[@]}"); fi
if [[ "$install_neovim" =~ ^[Yy]$ ]]; then PACMAN_PACKAGES+=("${NEOVIM_DEPS[@]}"); fi
if [[ "$install_wakeonlan" =~ ^[Yy]$ ]]; then PACMAN_PACKAGES+=("${WAKEONLAN_PACKAGES[@]}"); fi

# Check for BTRFS Root
if findmnt -n -o FSTYPE --target / | grep -q "btrfs"; then
    log "Btrfs root detected. Adding grub-btrfs and inotify-tools."
    PACMAN_PACKAGES+=(grub-btrfs inotify-tools)
else
    log "Root is not Btrfs. Skipping grub-btrfs."
fi

# --- INSTALLATION PHASE ---

log "Updating system..."
sudo pacman -Syu --noconfirm

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

log "Installing Official Packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

log "Installing AUR Packages..."
echo "" | paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

log "Installing Flatpak Apps..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub "${FLATPAK_APPS[@]}"

# --- SYSTEM CONFIGURATION ---

# Shell
if [[ "$SHELL" != *"zsh"* ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

# Dotfiles
if [[ "$stow_dotfiles" =~ ^[Yy]$ ]]; then
    if [ -d "$DOTFILES_DIR" ]; then
        log "Stowing dotfiles..."
        cd "$DOTFILES_DIR" || exit 1
        
        for folder in "${STOW_FOLDERS[@]}"; do
            if [ -d "$folder" ]; then
                echo -n "Stowing $folder... "
                stow -t "$HOME" --restow "$folder" 2>/dev/null && echo "Done." || echo "Failed."
            else
                warn "Skipping $folder (directory not found)."
            fi
        done
        cd - > /dev/null
    else
        error "Dotfiles directory not found at $DOTFILES_DIR."
    fi
    
    # Copy systemd service if it exists (Manual copy for system-wide services)
    if [ -f "$DOTFILES_DIR/systemd-system/wol.service" ]; then
        log "Installing wol.service..."
        sudo cp "$DOTFILES_DIR/systemd-system/wol.service" /etc/systemd/system/
        sudo systemctl daemon-reload
    fi
fi

# Gamescope Cap
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    if command -v gamescope &>/dev/null; then
        log "Setting CAP_SYS_NICE for Gamescope..."
        sudo setcap 'cap_sys_nice=+ep' "$(which gamescope)"
    fi
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
