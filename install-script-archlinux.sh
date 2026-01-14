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

# --- CONFIGURATION & PACKAGE LISTS ---

# Base Pacman Packages
PACMAN_PACKAGES=(
    # Core Desktop
    hyprland hypridle hyprlock hyprpaper hyprshot hyprpolkitagent
    hyprland-guiutils hyprutils uwsm waybar wofi swaync dbus wlsunset

    # Portals & Theming
    xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
    qt5-wayland qt6-wayland qt6ct gnome-themes-extra

    # Apps & Utils
    neovim nautilus yazi mpv fastfetch btop gnome-disk-utility
    obsidian pavucontrol gnome-keyring seahorse rsync ffmpeg
    ffmpegthumbnailer pipewire wireplumber

    # Shell & CLI
    kitty zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions starship
    fzf zoxide fd tmux stow bat eza ripgrep ncdu trash-cli man-db

    # Security & Networking
    ufw gnome-keyring seahorse keepassxc networkmanager bluez bluez-utils

    # Maintenance
    reflector

    # Containerization
    flatpak

    # Kernel & Headers
    linux-headers

    # Fonts
    ttf-cascadia-code-nerd ttf-ubuntu-font-family ttf-font-awesome
    ttf-dejavu ttf-liberation ttf-croscore noto-fonts noto-fonts-cjk noto-fonts-emoji

    # Declared packages
)

# Optional Groups
NVIDIA_PACKAGES=(libva-nvidia-driver nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland)
GAMING_PACKAGES=(gamemode gamescope mangohud steam)
NEOVIM_DEPS=(npm nodejs unzip clang go shellcheck zig luarocks dotnet-sdk cmake gcc imagemagick)
WAKEONLAN_PACKAGES=(wol ethtool)
VIRTUALIZATION_PACKAGES=(qemu libvirt virt-manager qemu-full dnsmasq bridge-utils)
OBS_GAME_RECORDING=(obs-studio obs-vkcapture)

# Flatpaks
FLATPAK_APPS=(
    it.mijorus.gearlever
    com.github.tchx84.Flatseal
    com.stremio.Stremio
    com.usebottles.bottles
    io.github.ebonjaeger.bluejay
    com.github.wwmm.easyeffects

    # Declared packages
)

# AUR Packages
AUR_PACKAGES=(
    timeshift-autosnap
    wayland-pipewire-idle-inhibit
    brave-bin
    nvibrant-bin
    pyprland

    # Declared packages
)

# Stow Packages
STOW_FOLDERS=(
    hypr backgrounds fastfetch kitty mpv nvim starship swaync waybar wofi yazi
    zsh tmux wayland-pipewire-idle-inhibit kwalletrc theme uwsm systemd-user
)

# --- ENVIRONMENT SETUP ---

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

# --- USER INTERACTION ---
echo ""
header "CONFIGURATION QUESTIONS"
read -r -p "$(echo -e "  ${YELLOW}??${NC} Install Gaming packages? (y/N): ")" install_gaming

if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    read -r -p "$(echo -e "  ${YELLOW}??${NC} Install OBS game recording packages? (y/N): ")" install_obs
fi

read -r -p "$(echo -e "  ${YELLOW}??${NC} Install NVIDIA drivers? (y/N): ")" install_nvidia
read -r -p "$(echo -e "  ${YELLOW}??${NC} Install Neovim dev tools? (y/N): ")" install_neovim
read -r -p "$(echo -e "  ${YELLOW}??${NC} Install WakeOnLan tools? (y/N): ")" install_wakeonlan
read -r -p "$(echo -e "  ${YELLOW}??${NC} Setup KVM virtualization? (y/N): ")" setup_virtualization
read -r -p "$(echo -e "  ${YELLOW}??${NC} Set up dotfiles with GNU Stow? (y/N): ")" stow_dotfiles
echo ""

# Modify Package Lists based on answers
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    log "Checking repositories for optimized Proton builds"
    if pacman -Ssq "^proton-cachyos$" >/dev/null &&
        pacman -Ssq "^proton-cachyos-slr$" >/dev/null; then

        GAMING_PACKAGES+=(proton-cachyos proton-cachyos-slr)
        log_task "Adding optimized Proton packages to queue."
        ok
    else
        warn "Proton-cachyos packages not found; skipping optimized builds."
    fi
fi

if [[ "$install_nvidia" =~ ^[Yy]$ ]]; then PACMAN_PACKAGES+=("${NVIDIA_PACKAGES[@]}"); fi
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    PACMAN_PACKAGES+=("${GAMING_PACKAGES[@]}")
    FLATPAK_APPS+=("com.vysp3r.ProtonPlus")
fi
if [[ "$install_obs" =~ ^[Yy]$ ]]; then AUR_PACKAGES+=("${OBS_GAME_RECORDING[@]}"); fi
if [[ "$install_neovim" =~ ^[Yy]$ ]]; then PACMAN_PACKAGES+=("${NEOVIM_DEPS[@]}"); fi
if [[ "$install_wakeonlan" =~ ^[Yy]$ ]]; then PACMAN_PACKAGES+=("${WAKEONLAN_PACKAGES[@]}"); fi

# Check for BTRFS Root
if findmnt -n -o FSTYPE --target / | grep -q "btrfs"; then
    log "Btrfs root detected. Adding grub-btrfs, inotify-tools, btrfsmaintenance, snapper and snap-pac."
    PACMAN_PACKAGES+=(grub-btrfs inotify-tools btrfsmaintenance snapper snap-pac)
else
    log "Root is not Btrfs. Skipping grub-btrfs."
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
    log "Rustup already installed."
fi

# Install Paru
if ! command -v paru &>/dev/null; then
    log_task "Installing Paru"
    if sudo pacman -S --needed --noconfirm base-devel git >/dev/null 2>&1 &&
        git clone https://aur.archlinux.org/paru.git /tmp/paru >/dev/null 2>&1 &&
        (cd /tmp/paru && makepkg -si --noconfirm >/dev/null 2>&1) &&
        rm -rf /tmp/paru; then ok; else fail; fi
else
    log "Paru already installed."
fi

# Install pacman pkgs
log "Installing Official Packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# Install AUR packages
log "Installing AUR Packages..."
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# Install Flatpaks
log "Installing Flatpak Apps..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub "${FLATPAK_APPS[@]}"

# Dotfiles
DOTFILES_DIR="$HOME/dotfiles"
if [[ "$stow_dotfiles" =~ ^[Yy]$ ]]; then
    header "DOTFILE CONFIGURATION"

    if [ -d "$DOTFILES_DIR" ]; then
        log "Stowing dotfiles..."
        cd "$DOTFILES_DIR"

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

        # Sync system-level files
        log "Syncing system-level files..."

        # Define your source directories
        SCRIPTS_SRC="$DOTFILES_DIR/scripts/system-scripts/usr/local/bin"
        CONFIGS_SRC="$DOTFILES_DIR/system-files"

        # Format: "source|target|mode"
        FILES_TO_SYNC=(
            "$SCRIPTS_SRC/reboot-to-windows|/usr/local/bin/reboot-to-windows|755"
            "$CONFIGS_SRC/root|/etc/snapper/configs/root|644"
        )

        for entry in "${FILES_TO_SYNC[@]}"; do
            IFS='|' read -r src target mode <<<"$entry"

            if [ -f "$src" ]; then
                mode=${mode:-644}

                log_task "Syncing $target (mode: $mode)"
                if sudo install -Dm "$mode" "$src" "$target"; then
                    ok
                else
                    fail
                fi
            else
                warn "Source file missing: $src"
            fi
        done
    fi
fi

# NVIDIA Configuration Block
if [[ "$install_nvidia" =~ ^[Yy]$ ]]; then
    header "NVIDIA SETUP"

    # Enable NVIDIA KMS
    CONF_FILE="/etc/modprobe.d/nvidia.conf"
    SETTING="options nvidia-drm modeset=1"

    if [ ! -f "$CONF_FILE" ] || ! grep -Fxq "$SETTING" "$CONF_FILE"; then
        log_task "Enabling NVIDIA Kernel Mode Setting (KMS)..."
        if echo "$SETTING" | sudo tee "$CONF_FILE" >/dev/null; then ok; else fail; fi
    else
        log "NVIDIA KMS already configured."
    fi

    # Inject NVIDIA modules into mkinitcpio for initramfs regeneration
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

# Gaming settings
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    header "GAMING CONFIGURATION"

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
            warn "NOTE: You may need to log out and back in for group changes to apply."
        else
            log "User already in gamemode group."
        fi
    else
        warn "'gamemoded' command not found. Skipping user group modification."
    fi

    # NTSYNC (Kernel Module)
    log_task "Enabling NTSYNC"
    if echo "ntsync" | sudo tee /etc/modules-load.d/ntsync.conf >/dev/null; then
        ok
    else
        fail
        warn "NTSYNC skipped. Windows games (Wine/Proton) may lack kernel-level sync support."
    fi
fi

# System configuration
header "SYSTEM CONFIGURATION"

# Shell
if command -v zsh >/dev/null 2>&1; then
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
        log_task "Changing shell to zsh"
        if chsh -s "$(command -v zsh)" "$USER"; then ok; else fail; fi
    else
        log "Shell is already set to zsh. Skipping."
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
        log "TPM already installed."
    fi
else
    warn "Tmux is not installed. Skipping TPM setup."
fi

# Setup WakeOnLan
if [[ "$install_wakeonlan" =~ ^[Yy]$ ]]; then
    log_task "Configuring Global & Active Wake-on-LAN"

    WOL_CONF="/etc/NetworkManager/conf.d/wol.conf"
    UDEV_RULE="/etc/udev/rules.d/81-wol.rules"

    # Persistent Global Config (for future connections)
    sudo mkdir -p /etc/NetworkManager/conf.d
    echo -e "[connection]\nethernet.wake-on-lan=magic" | sudo tee "$WOL_CONF" >/dev/null

    # Hardware-Level Rule (The "Nuclear" Option)
    echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="en*", RUN+="/usr/sbin/ethtool -s %k wol g"' | sudo tee "$UDEV_RULE" >/dev/null

    # Fix Existing Connections (Handles spaces in names)
    while IFS= read -r conn; do
        if [[ -n "$conn" ]]; then
            sudo nmcli connection modify "$conn" 802-3-ethernet.wake-on-lan magic 2>/dev/null
            sudo nmcli connection up "$conn" >/dev/null 2>&1
        fi
    done < <(nmcli -t -f NAME,TYPE connection show | grep ":802-3-ethernet" | cut -d: -f1)

    # Final Reload
    if sudo systemctl reload NetworkManager 2>/dev/null; then
        ok
    else
        # If NM isn't running, it's fine; the udev rule and conf file will catch it on next boot
        log "NetworkManager reload skipped; settings will apply on boot."
        ok
    fi
fi

# Setup virtualization
if [[ "$setup_virtualization" =~ ^[Yy]$ ]]; then
    header "Installing/Configuring Virtualization"

    # Install Packages
    log_task "Installing virtualization packages"
    if sudo pacman -S --needed --noconfirm "${VIRTUALIZATION_PACKAGES[@]}" &>/dev/null; then
        ok
    else
        fail
        error "Failed to install packages. Check your internet connection or package names."
    fi

    # Add user to groups
    for group in libvirt kvm; do
        if getent group "$group" >/dev/null; then
            log_task "Adding $(whoami) to $group group"
            if sudo usermod -aG "$group" "$(whoami)"; then ok; else fail; fi
        fi
    done

    # Enable and start libvirtd
    log_task "Enabling and starting libvirtd"
    if sudo systemctl enable --now libvirtd &>/dev/null; then ok; else fail; fi

    # Wait for the socket to be ready
    log_task "Waiting for QEMU socket"
    SOCKET_READY=false
    for _ in {1..5}; do
        if sudo virsh -c qemu:///system list --all >/dev/null 2>&1; then
            SOCKET_READY=true
            break
        fi
        sleep 1
    done
    if [ "$SOCKET_READY" = true ]; then ok; else fail; fi

    # Configure the default network
    log_task "Activating default network"
    sudo virsh -c qemu:///system net-autostart default &>/dev/null || true
    if sudo virsh -c qemu:///system net-start default &>/dev/null || true; then
        ok
    else
        fail
    fi

    echo ""
    success "Virtualization setup complete!"
    warn "Note: You must log out and back in for group changes to take effect."
fi

# Setup firewall
header "Firewall Configuration"

if command -v ufw &>/dev/null; then
    log "UFW detected. Applying security rules."

    log_task "Setting default policies (Deny Incoming / Allow Outgoing)"
    if sudo ufw default deny incoming &>/dev/null &&
        sudo ufw default allow outgoing &>/dev/null; then
        ok
    else
        fail
    fi

    log_task "Configuring port rules (SSH, HTTP, HTTPS)"
    if sudo ufw limit 22/tcp &>/dev/null &&
        sudo ufw allow 80/tcp &>/dev/null &&
        sudo ufw allow 443/tcp &>/dev/null; then
        ok
    else
        fail
    fi

    log_task "Enabling UFW"
    if echo "y" | sudo ufw enable &>/dev/null; then
        ok
        success "Firewall is active and configured."
    else
        fail
        error "Could not enable UFW."
    fi
else
    warn "UFW is not installed on this system."
    error "Firewall configuration skipped."
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
