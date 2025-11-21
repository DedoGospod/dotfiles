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

# Remove recent section from nautilus
gsettings set org.gnome.desktop.privacy remember-recent-files false


# Update the system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install rustup if not already installed
if ! command -v rustup &> /dev/null; then
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
if ! command -v paru &> /dev/null; then
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
    kitty
    uwsm
    hyprland
    hypridle
    hyprlock
    hyprpaper
    hyprshot
    neovim
    starship
    waybar
    wofi
    yazi
    nautilus
    swaync
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    hyprpolkitagent
    hyprland-guiutils
    hyprutils
    wlsunset
    qt5-wayland
    qt6-wayland
    zoxide
    zsh
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
    fzf
    qt6ct
    nwg-look
    btop
    dbus
    stow
    flatpak
    ttf-cascadia-code-nerd
    ttf-ubuntu-font-family
    ttf-font-awesome
    noto-fonts-emoji
    pavucontrol
    ripgrep
    mpv
    ffmpeg
    ffmpegthumbnailer
    fastfetch
    linux-headers
    linux-zen
    linux-zen-headers
    ncdu
    networkmanager
    reflector
    timeshift
    cronie
    pipewire
    wireplumber
    bat
    man
    tlp
    tmux
    gnome-disk-utility
    bluez
    bluez-utils
    gnome-themes-extra
    gnome-keyring
    seahorse
    obsidian
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
)

# AUR packages
aur_packages=(
    timeshift-autosnap
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
    pacman_packages+=(grub-btrfs)
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
        cd "$DOTFILES_DIR"

        # List of directories to stow
        stow_packages=(
            backgrounds
            fastfetch
            hypridle
            hyprland
            hyprlock
            hyprmocha
            hyprpaper
            kitty
            mpv
            nvim
            starship
            swaync
            waybar
            wofi
            yazi
            zshrc
            systemd
            tmux
            home-manager
            wayland-pipewire-idle-inhibit
        )

        # Stows packages (including systemd user services) and shows errors if any fail
        echo "---"
        echo "Stowing user packages (TARGET=\$HOME)..."
        for package in "${stow_packages[@]}"; do        

            if [ "$package" == "systemd" ]; then
                if [ -d "$package" ]; then
                    echo "Stowing systemd user package files..."
                    stow --restow --target="$HOME" "$package" || echo "ERROR stowing systemd user files"
                else
                    echo "Warning: Package $package not found in $DOTFILES_DIR"
                fi
                continue
            fi

            if [ -d "$package" ]; then
                echo "Stowing user package $package..."
                stow --restow --target="$HOME" "$package" || echo "ERROR stowing $package"
            else
                echo "Warning: Package $package not found in $DOTFILES_DIR"
            fi
        done
        
        # Stows system wide packages
        echo "Stowing system-wide files (REQUIRES SUDO)..."
        
        SYSTEMD_PACKAGE="systemd"

        if [ -d "$SYSTEMD_PACKAGE" ]; then
            echo "Stowing system-wide systemd package files (REQUIRES SUDO)..."
            sudo stow --restow --target=/ "$SYSTEMD_PACKAGE" || echo "ERROR stowing systemd system files"
        
            # Reload the systemd daemon to recognize the new system unit files
            echo "Reloading systemd daemon to recognize new system unit files..."
            sudo systemctl daemon-reload || echo "ERROR reloading systemd daemon"
        
            echo "Systemd stowed (user and system) and system daemon reloaded."
        else
            echo "Warning: Systemd package not found. Skipping systemd system setup."
        fi
        echo "---"
    else
        echo "Warning: Dotfiles directory $DOTFILES_DIR not found. Skipping stow."
    fi
fi

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
    echo "✅ tpm (tmux Plugin Manager) is already installed at: $TPM_PATH"
else
    echo "⚠️ tpm not found. Installing now..."
    if ! command -v git &> /dev/null; then
        echo "❌ Error: git is required but not found. Please install git."
        exit 1
    fi
    
    # Install tmux pkg manager
    echo "Installing tmux pkg manager from GitHub..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    
    if git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"; then
        echo "✅ tpm installed successfully!"
    else
        echo "❌ Error during tpm installation."
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
