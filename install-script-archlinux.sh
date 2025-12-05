#!/bin/bash

# Enable error checking for all commands
set -e

# Set XDG paths and application specific paths
echo "Setting XDG and application-specifc paths"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PYTHONHISTORY="$XDG_STATE_HOME/python/history"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"

# Create all Necessary XDG and application specific directories
echo "Creating XDG and application-specifc directories"
mkdir -p \
    "$XDG_DATA_HOME" \
    "$XDG_CONFIG_HOME" \
    "$XDG_STATE_HOME" \
    "$XDG_CACHE_HOME" \
    "${XDG_STATE_HOME}/zsh" \
    "${XDG_CACHE_HOME}/zsh" \
    "${XDG_DATA_HOME}/gnupg" \
    "${XDG_STATE_HOME}/python"

# Update the system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install rustup if not already installed
if ! command -v rustup &>/dev/null; then
    echo "Installing rustup using pacman..."
    if sudo pacman -S --noconfirm rustup; then
        echo "Rustup installed successfully via pacman."

        # Install the stable toolchain by default
        rustup default stable
        echo "Stable toolchain installed."
    else
        echo "Failed to install rustup using pacman.  Exiting."
        exit 1
    fi
else
    echo "Rustup is already installed."
fi

# Install paru if not already installed
if ! command -v paru &>/dev/null; then
    echo "Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
fi

# Ask if gaming-related packages should be installed
read -r -p "Do you want to install gaming-related packages? (y/N): " install_gaming

# Ask if NVIDIA drivers should be installed
read -r -p "Do you want to install NVIDIA drivers? (y/N): " install_nvidia

# Ask if Neovim related packages should be installed
read -r -p "Do you want to install Neovim related packages? (y/N): " install_neovim

# Ask if Extra packages should be installed
read -r -p "Do you want to install wakeonlan packages? (y/N): " install_wakeonlan

# Ask if dotfiles should be stowed
read -r -p "Do you want to set up dotfiles with GNU Stow? (y/N): " stow_dotfiles

# List of base pacman packages
pacman_packages=(
    # ---  Window Management & Core Desktop ---
    hyprland
    hypridle
    hyprlock
    hyprpaper
    hyprshot
    hyprpolkitagent
    hyprland-guiutils
    hyprutils
    uwsm
    waybar
    wofi
    swaync
    dbus
    wlsunset

    # ---  Desktop Portals & Theming ---
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland
    qt6ct
    gnome-themes-extra

    # ---  Applications & User Utilities ---
    kitty            # Terminal emulator
    neovim           # Text editor
    nautilus         # File manager (GUI)
    yazi             # TUI file manager
    mpv              # Media player
    fastfetch        # System info
    btop             # System monitor
    gnome-disk-utility # Disk utility
    obsidian         # Note-taking
    pavucontrol      # Volume mixer (GUI)
    gnome-keyring    # Keyring
    seahorse         # GUI frontend for gnome-keyring
    rsync            # Local or Server-to-Server file sync
    keepassxc        # Password manager & 2FA code generator 
    obs-studio       # Screen recording 

    # ---  Shell & CLI Enhancements ---
    zsh
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
    starship         # Prompt
    fzf              # Fuzzy finder
    zoxide           # Directory jumper
    fd               # Find files
    tmux             # Terminal multiplexer
    stow             # Dotfile management
    bat              # Cat clone
    eza              # Ls replacement
    ripgrep          # Grep alternative
    ncdu             # Disk usage
    trash-cli        # Safe delete
    man              # Man pages

    # ---  Networking & System Services ---
    networkmanager
    bluez            # Bluetooth service
    bluez-utils      # Bluetooth utilities
    pipewire         # Audio/Video server
    wireplumber      # Session manager for PipeWire
    tlp              # Power management
    cronie           # Scheduler

    # ---  System Maintenance & Utilities ---
    reflector        # Mirrorlist utility
    timeshift        # System backup
    ffmpeg           # Multimedia framework
    ffmpegthumbnailer # Thumbnailer for video files

    # ---  Containerization & Virtualization ---
    flatpak          # Universal package format

    # ---  Kernel & Headers ---
    linux-headers
    linux-zen
    linux-zen-headers

    # ---  Fonts ---
    ttf-cascadia-code-nerd
    ttf-ubuntu-font-family
    ttf-font-awesome
    ttf-dejavu
    ttf-liberation
    ttf-croscore
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

)

# NVIDIA driver packages
nvidia_packages=(
    libva-nvidia-driver
    nvidia-open-dkms
    nvidia-utils
    lib32-nvidia-utils
    nvidia-settings
    egl-wayland
)

# Gaming-related packages
gaming_packages=(
    gamemode
    gamescope
    mangohud
)

# Neovim related packages
neovim_packages=(
    npm
    nodejs
    unzip
    clang
    go
    shellcheck
    zig
    luarocks
    dotnet-sdk
    cmake
    gcc
    imagemagick

)

# Install WakeOnLan
wakeonlan=(
    wol
    ethtool
)

# Flatpak apps
flatpak_apps=(
    it.mijorus.gearlever
    com.github.tchx84.Flatseal
    com.stremio.Stremio
    com.usebottles.bottles
    com.vysp3r.ProtonPlus
    io.github.ebonjaeger.bluejay
    com.github.wwmm.easyeffects
)

# AUR packages
aur_packages=(
    timeshift-autosnap
    wayland-pipewire-idle-inhibit
    brave-bin
    nvibrant-bin
    obs-vkcapture
    pyprland
)

# Conditionally add NVIDIA packages
if [[ "$install_nvidia" =~ ^[Yy]$ ]]; then
    pacman_packages+=("${nvidia_packages[@]}")
fi

# Conditionally add gaming packages
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    pacman_packages+=("${gaming_packages[@]}")
fi

# Conditionally add Neovim packages
if [[ "$install_neovim" =~ ^[Yy]$ ]]; then
    pacman_packages+=("${neovim_packages[@]}")
fi

# Conditionally install wakeonlan packages
if [[ "$install_wakeonlan" =~ ^[Yy]$ ]]; then
    pacman_packages+=("${wakeonlan[@]}")
fi

# Check if root file system is btrfs
is_root_btrfs() {
    if findmnt -n -o FSTYPE --target / | grep -q "btrfs"; then
        return 0
    else
        return 1
    fi
}

# Install grub-btrfs if the filesystem is btrfs
echo "Checking root filesystem type for grub-btrfs..."
if is_root_btrfs; then
    echo "Root filesystem is Btrfs. Adding grub-btrfs to install list."
    pacman_packages+=(grub-btrfs **inotify-tools**)
else
    echo "Root filesystem is NOT Btrfs (Skipping grub-btrfs installation)."
fi

echo "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"

echo "Installing AUR packages..."
paru -S --needed --noconfirm "${aur_packages[@]}"

echo "Installing Flatpak apps..."
flatpak install -y --noninteractive flathub "${flatpak_apps[@]}"

# Set zsh as the default shell
echo "Setting zsh as the default shell..."
chsh -s "$(which zsh)"

# Stow dotfiles conditionally
if [[ "$stow_dotfiles" =~ ^[Yy]$ ]]; then
    echo "Setting up dotfiles with GNU Stow..."

    DOTFILES_DIR="$HOME/dotfiles"

    if [ -d "$DOTFILES_DIR" ]; then
        cd "$DOTFILES_DIR" || {
            echo "Failed to change directory to $DOTFILES_DIR. Aborting."
            exit 1
        }
        echo "Preparing to stow dotfiles from $PWD"

        # List of directories (packages) to stow
        stow_packages=(
            hypr
            backgrounds
            fastfetch
            kitty
            mpv
            nvim
            starship
            swaync
            waybar
            wofi
            yazi
            zshrc
            systemd-user
            tmux
            wayland-pipewire-idle-inhibit
            kwalletrc
            theme
            uwsm-autostart
        )

        # Loop through all packages and attempt to stow them
        for package in "${stow_packages[@]}"; do
            if [ -d "$package" ]; then
                echo -n "Stowing **$package**... "
                stow -t "$HOME" --no-folding "$package" 2>/dev/null && echo "Done." || echo "Failed."
            else
                echo "Skipping **$package**: Directory not found in $DOTFILES_DIR."
            fi
        done
    else
        echo "Skipping dotfile setup: Dotfiles directory **$DOTFILES_DIR** not found."
    fi
fi

# Copy systemd system services to the correct path
echo "Copying systemd system services to /etc/systemd/system"
sudo cp "$HOME"/dotfiles/systemd-system/wol.service /etc/systemd/system/
echo "Reloading systemd daemon"
sudo systemctl daemon-reload

# Gamescope setup for smooth performance
if [[ "$install_gaming" =~ ^[Yy]$ ]]; then
    echo "Setting up gamescope for smooth performance..."
    sudo setcap 'cap_sys_nice=+ep' "$(which gamescope)"
fi

# Set maxSnapshots to 1 for system updates
echo "Configuring autosnapshot..."
CONFIG_FILE="/etc/timeshift-autosnap.conf"

# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Timeshift autosnap configuration file not found at $CONFIG_FILE." >&2
    echo "Please check the path for your specific distribution (e.g., timeshift-autosnap-apt.conf)." >&2
    exit 1
fi

# Use sed to find the line beginning with maxSnapshots= and change the value to 1
sudo sed -i 's/^maxSnapshots=.*/maxSnapshots=1/' "$CONFIG_FILE"

# Verify the change
if grep -q "^maxSnapshots=1" "$CONFIG_FILE"; then
    echo "Successfully set maxSnapshots=1 in $CONFIG_FILE."
else
    echo "Warning: maxSnapshots value may not have been set correctly." >&2
fi

# Check if tmux pkg manager exists already
TPM_PATH="$HOME/.tmux/plugins/tpm"

# --- Check if tpm is already installed ---
if [ -d "$TPM_PATH" ]; then
    echo "tpm (tmux Plugin Manager) is already installed at: $TPM_PATH"
else
    echo "tpm not found. Installing now..."
    if ! command -v git &>/dev/null; then
        echo "Error: git is required but not found. Please install git."
        exit 1
    fi

    # Install tmux pkg manager
    echo "Installing tmux pkg manager from GitHub..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"

    if git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"; then
        echo "tpm installed successfully!"
    else
        echo "Error during tpm installation."
        exit 1
    fi
fi

# Finalizing the script with a reboot prompt
echo ""
echo "------------------------------------------------------"
echo "Installation and configuration tasks are complete! 🎉"
echo "A system reboot is highly recommended to apply all changes (e.g., kernel, drivers, shell change)."
echo "------------------------------------------------------"

# Ask for a reboot
read -r -p "Would you like to reboot now? (Y/n): " reboot_now

if [[ "$reboot_now" =~ ^[Yy]$ || -z "$reboot_now" ]]; then
    echo "Rebooting in 5 seconds..."
    sleep 5
    sudo reboot
else
    echo "Reboot declined. Please manually reboot your system at your earliest convenience for changes to take full effect."
    echo "To start your new desktop environment, you may need to log out and log back in, or manually execute the 'Hyprland' session from your display manager."
fi
