#!/bin/bash

# Check if hypridle is running
HYPRIDLE_RUNNING=$(pgrep -x "hypridle")

if [ -n "$HYPRIDLE_RUNNING" ]; then
    # hypridle is running, so stop it and stop sway-audio-idle-inhibit
    systemctl --user stop --now hypridle.service
    systemctl --user stop --now wayland-pipewire-idle-inhibit.service
    notify-send -t 1000 "SLEEP DISABLED."
    echo "SLEEP DISABLED"
else
    # hypridle is not running, so start it and start sway-audio-idle-inhibit
    systemctl --user start --now hypridle.service
    systemctl --user start --now wayland-pipewire-idle-inhibit.service
    notify-send -t 1000 "SLEEP ENABLED"
    echo "SLEEP ENABLED"
fi
