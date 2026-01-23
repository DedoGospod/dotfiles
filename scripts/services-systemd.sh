#!/usr/bin/env bash

# ==============================================================================
#  Setup & Dependencies
# ==============================================================================
FUNCTIONS_DIR="$HOME/dotfiles/scripts/setup-scripts/functions/"

if [[ -f "$FUNCTIONS_DIR/systemd-setup-functions.sh" ]]; then
    # shellcheck source=/dev/null
    source "$FUNCTIONS_DIR/systemd-setup-functions.sh"
else
    echo "ERROR: systemd-setup-functions.sh not found!"
    exit 1
fi

# ==============================================================================
#  Initialization
# ==============================================================================
log_info "Verifying sudo access..."
sudo -v

log_info "Reloading systemd daemons..."
sudo systemctl daemon-reload
systemctl --user daemon-reload

# ==============================================================================
#  System Services (Root)
# ==============================================================================
echo ""
log_info "--- Configuring System Services ---"

manage_service "NetworkManager.service"         ""      "enable"  "Network management"      "Y"
manage_service "bluetooth.service"              ""      "enable"  "Bluetooth connectivity"  "n"
manage_service "power-profiles-daemon.service"  ""      "enable"  "Power profiles"          "Y"
manage_service "ufw.service"                    ""      "enable"  "Enable firewall"         "Y"

# Timers

# ==============================================================================
#  User Services
# ==============================================================================
echo ""
log_info "--- Configuring User Services ---"

IS_HYPRLAND=false
if [[ "${XDG_SESSION_DESKTOP:-}" == "Hyprland" || -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    IS_HYPRLAND=true
    log_info "Hyprland environment detected."
fi

if $IS_HYPRLAND; then
    manage_service "hypridle.service"        "--user"  "enable"  "Idle daemon"             "Y"
    manage_service "hyprpaper.service"       "--user"  "enable"  "Wallpaper daemon"        "Y"
    manage_service "pyprland.service"        "--user"  "enable"  "Pyprland plugins"        "Y"
    manage_service "hyprpolkitagent.service" "--user"  "enable"  "Polkit Authentication"   "Y"
    manage_service "waybar.service"          "--user"  "enable"  "Status bar"              "Y"
    manage_service "hyprsunset.service"      "--user"  "enable"  "blue light filter"       "Y"
else
    echo "  [User] Not in Hyprland. Skipping Hyprland-specific services."
fi

# ------------------------------------------------------------------------------
# Conditional Selection
# ------------------------------------------------------------------------------

select_exclusive_service "Blue light filter" "--user" "wlsunset.service" "hyprsunset.service"
# select_exclusive_service "Status bar"        "--user" "waybar.service" "ironbar.service"

# ------------------------------------------------------------------------------
# General User Services
# ------------------------------------------------------------------------------

manage_service "wayland-pipewire-idle-inhibit.service" "--user"  "enable"  "Prevent sleep when playing audio" "Y"
manage_service "swaync.service"                        "--user"  "enable"  "Notification daemon"              "Y"
manage_service "obs.service"                           "--user"  "enable"  "OBS-STUDIO"                       "n"

# Timers
manage_service "gearlever-update.timer"                "--user"  "enable"  "Gearlever auto-update"            "Y"

# ==============================================================================
#  Completion
# ==============================================================================

echo ""
log_success "Configuration complete!"
