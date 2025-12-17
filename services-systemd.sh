#!/bin/bash

# ==============================================================================
#  System & User Service Configuration Manager
# ==============================================================================

# Exit on error, undefined variable, or pipe failure
set -euo pipefail

# --- Visuals ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[ACTION]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if a service unit file exists (works for both user and system)
# Usage: service_exists "service_name" "scope (--user or empty)"
service_exists() {
    local service="$1"
    local scope="${2:-}"
    
    # We use 'systemctl list-unit-files' to check existence rather than LoadState
    # because a service might not be loaded yet but still exists on disk.
    if systemctl "$scope" list-unit-files "$service" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Core logic to manage a single service
# Usage: manage_service "name" "scope" "action(enable/disable)" "description" "default(Y/n)"
manage_service() {
    local service="$1"
    local scope="$2"      # pass "--user" for user services, empty for system
    local action="$3"     # "enable" or "disable"
    local desc="$4"
    local default="$5"    # "Y" or "n"

    # Determine scope label for logging
    local scope_label="System"
    [[ "$scope" == "--user" ]] && scope_label="User"

    # Check if service exists first
    if ! service_exists "$service" "$scope"; then
        echo -e "  [${scope_label}] Service ${YELLOW}$service${NC} not found. Skipping."
        return
    fi

    # Format the prompt
    local prompt_str="  ${YELLOW}??${NC} Do you want to ${action^^} ${BLUE}$service${NC} ($desc)? "
    if [[ "$default" == "Y" ]]; then
        prompt_str+="[Y/n]: "
    else
        prompt_str+="[y/N]: "
    fi

    # Ask user
    read -r -p "$(echo -e "$prompt_str")" choice
    
    # Normalize empty choice to default
    if [[ -z "$choice" ]]; then
        choice="$default"
    fi

    # Process choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo -e "     Process: ${action}ing $service..."
        
        # Execute command (use sudo for system, standard for user)
        if [[ "$scope" == "--user" ]]; then
            systemctl --user "$action" --now "$service"
        else
            sudo systemctl "$action" --now "$service"
        fi
        log_success "$service ${action}d."
    else
        echo -e "     Skipping $service."
    fi
}

# ==============================================================================
#  Initialization
# ==============================================================================

# Ensure user can sudo upfront to prevent interruptions later
log_info "Verifying sudo access..."
sudo -v

log_info "Reloading systemd daemons..."
sudo systemctl daemon-reload
systemctl --user daemon-reload

# ==============================================================================
#  System Services
# ==============================================================================

echo ""
log_info "--- Configuring System Services ---"

# Disable Wait Online (Speed up boot)
manage_service "systemd-networkd-wait-online.service" "" "disable" "potentially faster boot" "n"

# Standard Services
manage_service "cronie.service"    "" "enable" "Scheduled tasks" "Y"
manage_service "bluetooth.service" "" "enable" "Bluetooth connectivity" "n"
manage_service "wol.service"       "" "enable" "Wake on LAN" "n"
manage_service "power-profiles-daemon.service" "" "enable" "Power profiles" "Y"

# Special Logic: Grub Btrfs
ROOT_FS=$(findmnt -n -o FSTYPE /)
if [[ "$ROOT_FS" == "btrfs" ]]; then
    manage_service "grub-btrfsd.service" "" "enable" "Auto-update grub on snapshots" "Y"
else
    echo -e "  [System] Root is not Btrfs ($ROOT_FS). Skipping grub-btrfsd."
fi

# Special Logic: NTSYNC (Kernel Module)
echo ""
read -r -p "$(echo -e "  ${YELLOW}??${NC} Enable NTSYNC (Kernel module for gaming)? [Y/n]: ")" NTSYNC_CHOICE
if [[ "$NTSYNC_CHOICE" =~ ^[Yy]$ || -z "$NTSYNC_CHOICE" ]]; then
    if echo "ntsync" | sudo tee /etc/modules-load.d/ntsync.conf > /dev/null; then
        log_success "NTSYNC enabled (added to modules-load.d)."
    else
        log_error "Failed to write NTSYNC config."
    fi
else
    echo -e "     Skipping NTSYNC."
fi


# ==============================================================================
#  User Services
# ==============================================================================

echo ""
log_info "--- Configuring User Services ---"

# Check for Hyprland context
IS_HYPRLAND=false
if [[ "${XDG_SESSION_DESKTOP:-}" == "Hyprland" || -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    IS_HYPRLAND=true
    log_info "Hyprland environment detected."
fi

if $IS_HYPRLAND; then
    manage_service "hypridle.service"        "--user" "enable" "Idle daemon" "Y"
    manage_service "hyprpaper.service"       "--user" "enable" "Wallpaper daemon" "Y"
    manage_service "waybar.service"          "--user" "enable" "Status bar" "Y"
    manage_service "pyprland.service"        "--user" "enable" "Pyprland plugins" "Y"
    manage_service "hyprpolkitagent.service" "--user" "enable" "Polkit Authentication" "Y"
    manage_service "wlsunset.service"        "--user" "enable" "Blue light filter" "Y"
    manage_service "swaync.service"          "--user" "enable" "Notification daemon" "Y"
else
    echo "  [User] Not in Hyprland. Skipping Hyprland-specific services."
fi

# General user services
manage_service "wayland-pipewire-idle-inhibit.service" "--user" "enable" "Prevent sleep when playing audio" "Y"
manage_service "easyeffects.service"                   "--user" "enable" "Audio effects/Equalizer" "n"
manage_service "obs.service"                           "--user" "enable" "OBS Studio" "n"
manage_service "gpu-screen-recorder-replay.service"    "--user" "enable" "GPU Screen recorder" "n"

echo ""
log_success "Configuration complete!"
