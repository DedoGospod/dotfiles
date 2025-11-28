#!/usr/bin/env bash

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

# Stow dotfiles
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

# Stowing system packages
echo "stowing system packages"
sudo stow -t / --no-folding systemd-system

# Set zsh as the default shell
echo "Setting zsh as the default shell..."
chsh -s "$(which zsh)"

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

# Install tmux pkg manager
TPM_PATH="$HOME/.tmux/plugins/tpm"

# --- Check if tpm is already installed ---
if [ -d "$TPM_PATH" ]; then
    echo "tpm (tmux Plugin Manager) is already installed at: $TPM_PATH"
else
    # --- Install tpm if it's not found ---
    echo "tpm not found. Installing now..."
    # Ensure git is installed before running the clone command
    if ! command -v git &> /dev/null; then
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
