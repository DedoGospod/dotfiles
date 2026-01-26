#!/usr/bin/env bash

# ==============================================================================
#  Setup & Dependencies
# ==============================================================================

# Source functions
FUNCTIONS_DIR="$HOME/dotfiles/scripts/setup-scripts/functions/"
# shellcheck source=/dev/null
source "$FUNCTIONS_DIR/service-management-functions"

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

# ------------------------------------------------------------------------------
# User Services
# ------------------------------------------------------------------------------
header "Configuring general user services"

# Environment specific user Services
configure_hyprland_services

# Conditional Selection
select_exclusive_service "Blue light filter"            "--user" "wlsunset.service" "hyprsunset.service"

# General services
manage_service "wayland-pipewire-idle-inhibit.service"  "--user" "enable" "Prevent sleep when playing audio"  "Y"
manage_service "swaync.service"                         "--user" "enable" "Notification daemon"               "Y"
manage_service "obs.service"                            "--user" "enable" "OBS studio autostart with replay"  "n"

# Timers
