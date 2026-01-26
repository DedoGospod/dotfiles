#!/usr/bin/env bash


# Check if hypridle is running
HYPRIDLE_RUNNING=$(pgrep -x "hypridle")

if [ -n "$HYPRIDLE_RUNNING" ]; then
    # hypridle is running, so stop it (Power Management OFF)
    systemctl --user stop --now hypridle.service
    systemctl --user stop --now wayland-pipewire-idle-inhibit.service
    
    # Use "Coffee" or "Video Display" icon to indicate the screen stays on
    notify-send -t 1500 --icon=weather-clear "SLEEP DISABLED" "System will stay awake"
    echo "SLEEP DISABLED"
else
    # hypridle is not running, so start it (Power Management ON)
    systemctl --user start --now hypridle.service
    systemctl --user start --now wayland-pipewire-idle-inhibit.service
    
    # Use "Preferences Desktop Screensaver" to show sleep is active
    notify-send -t 1500 --icon=preferences-desktop-screensaver "SLEEP ENABLED" "Sleep has been activated"
    echo "SLEEP ENABLED"
fi
