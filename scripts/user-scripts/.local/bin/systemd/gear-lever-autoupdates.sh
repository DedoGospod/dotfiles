#!/usr/bin/env bash

# Initial notification
notify-send -t 1500 "Gear Lever" "Checking for AppImage updates..." --icon=system-software-update

# Run command and capture ALL output (stdout + stderr)
LOG_OUTPUT=$(flatpak run it.mijorus.gearlever --fetch-updates 2>&1)
EXIT_STATUS=$?

# Send Status Notification
if [ $EXIT_STATUS -eq 0 ]; then
    notify-send -t 2000 "Gear Lever: Success" "Updates finished successfully." --icon=system-software-update
else
    notify-send -t 3000 "Gear Lever: Failed" "An error occurred (Exit Code: $EXIT_STATUS)." --icon=dialog-error --urgency=critical
fi

# This checks if the output contains anything other than spaces/newlines
if [ -n "$(echo "$LOG_OUTPUT" | tr -d '[:space:]')" ]; then
    notify-send -t 5000 "Gear Lever Logs" "$LOG_OUTPUT" --icon=document-new
fi
