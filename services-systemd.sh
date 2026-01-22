#!/usr/bin/env bash


# Source necessary functions
SCRIPT_DIR="$HOME/dotfiles/scripts/setup-scripts/"

if [[ -f "$SCRIPT_DIR/services-setup-functions.sh" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/services-setup-functions.sh"
else
    log_error "services-setup-functions.sh not found!"
    exit 1
fi

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

# Standard Services
manage_service "NetworkManager.service"                "" "enable" "Network management" "Y"
manage_service "bluetooth.service"                     "" "enable" "Bluetooth connectivity" "n"
manage_service "power-profiles-daemon.service"         "" "enable" "Power profiles" "Y"
manage_service "ufw.service"                           "" "enable" "Enable firewall" "Y"

# System timers

# Special Logic: Grub Btrfs
ROOT_FS=$(findmnt -n -o FSTYPE /)

if [[ "$ROOT_FS" == "btrfs" ]]; then

    # Grub Btrfs Daemon
    log_task "Enabling grub-btrfsd.service"
    if sudo systemctl enable --now grub-btrfsd.service; then ok; else fail; fi

    # Snapper Timeline
    log_task "Enabling snapper-timeline.timer"
    if sudo systemctl enable --now snapper-timeline.timer; then ok; else fail; fi

    # Snapper Cleanup
    log_task "Enabling snapper-cleanup.timer"
    if sudo systemctl enable --now snapper-cleanup.timer; then ok; else fail; fi

    # Btrfs Scrub
    log_task "Enabling btrfs-scrub.timer"
    if sudo systemctl enable --now btrfs-scrub.timer; then ok; else fail; fi

    # Btrfs Balance
    log_task "Enabling btrfs-balance.timer"
    if sudo systemctl enable --now btrfs-balance.timer; then ok; else fail; fi
else
    echo -e "  [System] Root is not Btrfs ($ROOT_FS). Skipping Btrfs tasks."
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
    manage_service "hypridle.service"                  "--user" "enable" "Idle daemon" "Y"
    manage_service "hyprpaper.service"                 "--user" "enable" "Wallpaper daemon" "Y"
    manage_service "pyprland.service"                  "--user" "enable" "Pyprland plugins" "Y"
    manage_service "hyprpolkitagent.service"           "--user" "enable" "Polkit Authentication" "Y"
    manage_service "waybar.service"                    "--user" "enable" "Status bar" "Y"
    manage_service "hyprsunset.service"                "--user" "enable" "Blue light filter" "Y"

else
    echo "  [User] Not in Hyprland. Skipping Hyprland-specific services."
fi

# select_exclusive_service "Blue light filter" "--user" "wlsunset.service" "hyprsunset.service"

# General user services
manage_service "wayland-pipewire-idle-inhibit.service" "--user" "enable" "Prevent sleep when playing audio" "Y"
manage_service "swaync.service"                        "--user" "enable" "Notification daemon" "Y"
manage_service "obs.service"                           "--user" "enable" "OBS-STUDIO" "n"

# User timers
manage_service "gearlever-update.timer"                "--user" "enable" "Gearlever auto-update" "Y"

echo ""
log_success "Configuration complete!"
