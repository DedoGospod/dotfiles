#!/bin/bash

# Identify the OBS process (works for Flatpak and Native)
OBS_PROC=$(pgrep -x "obs" || pgrep -x ".obs-wrapped")

if [ -n "$OBS_PROC" ]; then
    # Send Replay saved notification
    ICON="/usr/share/icons/hicolor/256x256/apps/com.obsproject.Studio.png"
    notify-send -i "$ICON" -t 1000 "Replay Saved" "OBS Buffer Captured"
else
    # Notify if OBS isn't open
    notify-send "OBS Error" "OBS is not running"
fi
