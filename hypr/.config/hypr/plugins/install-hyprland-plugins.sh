#!/bin/bash

# --- Configuration ---
HYPRPM_REPOS=(
    "https://github.com/hyprwm/hyprland-plugins"
    "https://github.com/horriblename/hyprgrass"
)

PLUGINS_TO_ENABLE=(
    "hyprgrass"
)

# --- Helpers ---
# specific colors for nice formatting
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[LOG]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err() { echo -e "${RED}[ERR]${NC} $1"; }

# --- Execution ---
log "Starting Hyprland Plugin Automation..."

# Check if hyprpm exists
if ! command -v hyprpm &> /dev/null; then
    err "hyprpm not found. Please install it first."
    exit 1
fi

# Ensure Headers are up to date
log "Updating Hyprland headers and repositories..."
if ! hyprpm update; then
    err "Failed to update headers. Check your internet or Hyprland version."
    exit 1
fi

# Add Repositories (checks if the plugin is already listed to avoid re-cloning/re-compiling unnecessarily)
INSTALLED_PLUGINS=$(hyprpm list)
for repo in "${HYPRPM_REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    if echo "$INSTALLED_PLUGINS" | grep -q "$repo_name"; then
        log "Repository $repo_name appears to be installed. Skipping add."
    else
        log "Repository $repo_name not found. Adding and compiling (this may take a while)..."
        if ! hyprpm add "$repo"; then
             err "Failed to add repo: $repo"
             exit 1
        fi
    fi
done

# Enable Plugins
log "Enabling plugins..."
for plugin in "${PLUGINS_TO_ENABLE[@]}"; do
    # Check if enabled already to keep output clean, though enable is usually safe to spam
    if hyprpm enable "$plugin"; then
        log "Enabled: $plugin"
    else
        warn "Failed to enable: $plugin (It might not be installed or name is wrong)"
    fi
done

# Hot Reload
log "Reloading Hyprland plugins..."
if hyprpm reload; then
    log "Plugins reloaded successfully!"
else
    warn "Reload failed. You might need to restart Hyprland manually."
fi

exit 0
