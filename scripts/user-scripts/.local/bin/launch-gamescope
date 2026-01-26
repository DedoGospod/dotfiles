#!/usr/bin/env bash

# Gamescope setup. Includes: mouse raw input, performance optimizations, and resolution scaling

set -e

# Detect if running on Steam Deck hardware
if [[ $(cat /sys/devices/virtual/dmi/id/product_name) == "Steam Deck" ]]; then
    IS_STEAM_DECK="true"
fi

# Default Gamescope options
GAMESCOPE_OPTS=(
    # Display
    --prefer-vk-device 0
    --rt              # Real-time scheduling
    --hdr-enabled     # Enable HDR if available
    --framerate-limit "$(( ${GAMESCOPE_REFRESH:-165} * 2 ))"
    --nested-refresh "${GAMESCOPE_REFRESH:-165}"

    # Mouse settings
    --mouse-sensitivity 1.0
    --force-grab-cursor

    # Performance
    --immediate-flips
    --disable-layers

    # Fullscreen
    --fullscreen
)

# Steam Deck-specific adjustments
if [ "$IS_STEAM_DECK" = "true" ]; then
    GAMESCOPE_OPTS+=(
        --steam
        --steam-dedicated-focus
    )
fi

# Resolution handling
if [ -n "$GAMESCOPE_WIDTH" ] && [ -n "$GAMESCOPE_HEIGHT" ]; then
    GAMESCOPE_OPTS+=(
        -W "$GAMESCOPE_WIDTH"
        -H "$GAMESCOPE_HEIGHT"
    )
else
    # Fallback to 1080p if no resolution specified
    GAMESCOPE_OPTS+=(
        -W 1920
        -H 1080
    )
fi

# Steam launch options
STEAM_OPTS=(
    -steamos
    -steampal
    -steam3
    -noverifyfiles
    -nobigpicture
)

# Launch Gamescope + Steam
exec gamescope "${GAMESCOPE_OPTS[@]}" -- steam "${STEAM_OPTS[@]}"
