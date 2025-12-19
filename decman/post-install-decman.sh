#!/usr/bin/env bash

TPM_PATH="$HOME/.tmux/plugins/tpm"
TS_CONFIG="/etc/timeshift-autosnap.conf"
DOTFILES_DIR="$HOME/dotfiles"

# Tmux Plugin Manager
if [ ! -d "$TPM_PATH" ]; then
    log "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
else
    log "TPM already installed."
fi

# Timeshift Autosnap Config
if [ -f "$TS_CONFIG" ]; then
    log "Configuring Timeshift maxSnapshots..."
    sudo sed -i 's/^maxSnapshots=.*/maxSnapshots=1/' "$TS_CONFIG"
fi

# Shell
log "Setting zsh as default shell"
if [[ "$SHELL" != *"zsh"* ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
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

# Run services setup
if [ -d "$DOTFILES_DIR" ]; then
    log "Stowing dotfiles..."
    cd "$DOTFILES_DIR" || exit 1
    ./services-systemd.sh
fi
