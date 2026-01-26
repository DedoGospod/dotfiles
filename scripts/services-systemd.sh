#!/usr/bin/env bash

# ==============================================================================
#  Setup & Dependencies
# ==============================================================================

# Source functions
FUNCTIONS_DIR="$HOME/dotfiles/scripts/setup-scripts/functions/"
if [[ -d "$FUNCTIONS_DIR" ]]; then
    for func_file in "$FUNCTIONS_DIR"/*; do
        if [[ -f "$func_file" ]]; then
            # shellcheck source=/dev/null
            source "$func_file"
        fi
    done
else
    echo "Directory $FUNCTIONS_DIR not found"
    exit 1
fi

# ==============================================================================
#  Initialization
# ==============================================================================
log "Verifying sudo access..."
sudo -v

log_task "Reloading systemd daemons"
sudo systemctl daemon-reload
systemctl --user daemon-reload
ok

# ==============================================================================
#  System Services (Root)
# ==============================================================================
header "Configuring System Services"

manage_service "NetworkManager.service"         "" "enable" "Network management"     "Y"
manage_service "bluetooth.service"              "" "enable" "Bluetooth connectivity" "n"
manage_service "power-profiles-daemon.service"  "" "enable" "Power profiles"         "Y"
manage_service "ufw.service"                    "" "enable" "Enable firewall"        "Y"

# Timers
if_arch "enabling paccache timer" sudo systemctl enable --now paccache.timer

# ==============================================================================
#  Environment specific user Services
# ==============================================================================

configure_hyprland_services

# ------------------------------------------------------------------------------
# Conditional Selection
# ------------------------------------------------------------------------------

select_exclusive_service "Blue light filter"            "--user" "wlsunset.service" "hyprsunset.service"
# select_exclusive_service "Status bar"                   "--user" "waybar.service" "ironbar.service"

# ------------------------------------------------------------------------------
# General User Services
# ------------------------------------------------------------------------------

header "Configuring general user services"

manage_service "wayland-pipewire-idle-inhibit.service"  "--user" "enable" "Prevent sleep when playing audio"  "Y"
manage_service "swaync.service"                         "--user" "enable" "Notification daemon"               "Y"
manage_service "obs.service"                            "--user" "enable" "OBS studio autostart with replay"  "n"

# Timers
