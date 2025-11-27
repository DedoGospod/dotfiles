#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to check if a SYSTEM-LEVEL service unit file exists.
service_exists() {
    systemctl list-unit-files --no-pager --type=service | grep -Fq "$1"
}

# Function to check if a USER-LEVEL service unit file exists.
user_service_exists() {
    systemctl --user list-unit-files --no-pager --type=service | grep -Fq "$1"
}

# --- SYSTEM SERVICES ---

echo "Starting System Services Configuration..."

# Disable systemd-networkd-wait-online service
SERVICE="systemd-networkd-wait-online.service"
if service_exists "$SERVICE"; then
    read -r -p "Do you want to DISABLE $SERVICE for potentially faster boot? (y/N): " WAIT_CHOICE
    if [[ "$WAIT_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Disabling $SERVICE..."
        sudo systemctl disable --now "$SERVICE"
    else
        echo "Skipping disabling $SERVICE."
    fi
else
    echo "Service $SERVICE not found. Skipping."
fi

# Enable cronie.service
SERVICE="cronie.service"
if service_exists "$SERVICE"; then
    read -r -p "Do you want to ENABLE $SERVICE for scheduled tasks? (Y/n): " CRONIE_CHOICE
    if [[ "$CRONIE_CHOICE" =~ ^[Yy]$ || -z "$CRONIE_CHOICE" ]]; then
        echo "Enabling $SERVICE..."
        sudo systemctl enable --now "$SERVICE"
    else
        echo "Skipping enabling $SERVICE."
    fi
else
    echo "Service $SERVICE not found. Skipping."
fi

# Enable TLP power saving
SERVICE="tlp.service"
if service_exists "$SERVICE"; then
    read -r -p "Is this system a device that requires TLP power management? (y/N): " TLP_CHOICE
    if [[ "$TLP_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Enabling $SERVICE..."
        sudo systemctl enable --now "$SERVICE"
    else
        echo "Skipping TLP service as requested."
    fi
else
    echo "Service $SERVICE not found. Skipping."
fi

# Enable bluetooth service
SERVICE="bluetooth.service"
if service_exists "$SERVICE"; then
    read -r -p "Do you use Bluetooth devices on this system? (y/N): " BLUETOOTH_CHOICE
    if [[ "$BLUETOOTH_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Enabling $SERVICE..."
        sudo systemctl enable --now "$SERVICE"
    else
        echo "Skipping Bluetooth service as requested."
    fi
else
    echo "Service $SERVICE not found. Skipping."
fi

# Enable grub-btrfs daemon
SERVICE="grub-btrfsd.service"
if service_exists "$SERVICE"; then
    read -r -p "Do you want to ENABLE $SERVICE for grub btrfs rollbacks? (y/N): " GRUB_CHOICE
    if [[ "$GRUB_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Enabling $SERVICE..."
        sudo systemctl enable --now "$SERVICE"
    else
        echo "Skipping enabling $SERVICE."
    fi
else
    echo "Service $SERVICE not found. Skipping."
fi

# Enable wol.service
SERVICE="wol.service"
if service_exists "$SERVICE"; then
    read -r -p "Do you want to ENABLE $SERVICE for WOL functionality? (y/N): " WOL_CHOICE
    if [[ "$WOL_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Enabling $SERVICE..."
        sudo systemctl enable --now "$SERVICE"
    else
        echo "Skipping enabling $SERVICE."
    fi
else
    echo "Service $SERVICE not found. Skipping."
fi

# --- USER SERVICES ---

echo
echo "Starting User Services Configuration..."

# Check for Wayland/Hyprland environment before enabling related user services
if [ -n "$WAYLAND_DISPLAY" ] && [[ "$XDG_SESSION_DESKTOP" == "Hyprland" || -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "Detected Wayland/Hyprland session. Enabling Hyprland-specific services..."

    # Enable hypridle
    SERVICE="hypridle.service"
    if user_service_exists "$SERVICE"; then
        read -r -p "Enable $SERVICE (Hyprland idle/lock manager)? (y/N): " HYPRIDLE_CHOICE
        if [[ "$HYPRIDLE_CHOICE" =~ ^[Yy]$ ]]; then
            echo "Enabling $SERVICE..."
            systemctl --user enable --now "$SERVICE"
        else
            echo "Skipping enabling $SERVICE."
        fi
    else
        echo "Service $SERVICE not found (user context). Skipping."
    fi

    # Enable hypridle
    SERVICE="hyprwhenthen.service"
    if user_service_exists "$SERVICE"; then
        read -r -p "Enable $SERVICE (Hyprland idle/lock manager)? (y/N): " HYPRWHENTHEN_CHOICE
        if [[ "$HYPRWHENTHEN_CHOICE" =~ ^[Yy]$ ]]; then
            echo "Enabling $SERVICE..."
            systemctl --user enable --now "$SERVICE"
        else
            echo "Skipping enabling $SERVICE."
        fi
    else
        echo "Service $SERVICE not found (user context). Skipping."
    fi

    # Enable hyprpolkitagent
    SERVICE="hyprpolkitagent.service"
    if user_service_exists "$SERVICE"; then
        read -r -p "Enable $SERVICE (Polkit authentication agent)? (y/N): " POLKIT_CHOICE
        if [[ "$POLKIT_CHOICE" =~ ^[Yy]$ ]]; then
            echo "Enabling $SERVICE..."
            systemctl --user enable --now "$SERVICE"
        else
            echo "Skipping enabling $SERVICE."
        fi
    else
        echo "Service $SERVICE not found (user context). Skipping."
    fi
else
    echo "Wayland/Hyprland environment not detected. Skipping user services (hypridle, wlsunset, etc.)."
fi

# Enable wayland-pipewire-idle-inhibit
SERVICE="wayland-pipewire-idle-inhibit.service"
if user_service_exists "$SERVICE"; then
    read -r -p "Enable $SERVICE (wayland-pipewire-idle-inhibit)? (y/N): " WAYLAND_PIPEWIRE_IDLEINHIBIT_CHOICE
    if [[ "$WAYLAND_PIPEWIRE_IDLEINHIBIT_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Enabling $SERVICE..."
        systemctl --user enable --now "$SERVICE"
    else
        echo "Skipping enabling $SERVICE."
    fi
else
    echo "Service $SERVICE not found (user context). Skipping."
fi

# Enable Blue light filter
SERVICE="wlsunset.service"
if user_service_exists "$SERVICE"; then
    read -r -p "Enable $SERVICE (Blue light filter/Sunset service)? (y/N): " SUNSET_CHOICE
    if [[ "$SUNSET_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Enabling $SERVICE..."
        systemctl --user enable --now "$SERVICE"
    else
        echo "Skipping enabling $SERVICE."
    fi
else
    echo "Service $SERVICE not found (user context). Skipping."
fi

# Enable OBS Studio service
SERVICE="obs.service"
if user_service_exists "$SERVICE"; then
    read -r -p "Enable $SERVICE (OBS Studio streaming/recording)? (y/N): " OBS_CHOICE
    if [[ "$OBS_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Enabling $SERVICE..."
        systemctl --user enable --now "$SERVICE"
    else
        echo "Skipping enabling $SERVICE."
    fi
else
    echo "Service $SERVICE not found (user context). Skipping."
fi

# Service setup complete
echo "Service setup complete!"
