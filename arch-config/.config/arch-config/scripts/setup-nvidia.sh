#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Helper Functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create UWSM directory if it doesnt already exist
if command -v uwsm >/dev/null 2>&1; then
    log "UWSM found. Preparing configuration directory..."
    mkdir -p "$HOME/.config/uwsm"
else
    warn "UWSM not detected. Skipping uwsm directory configuration ..."
fi

# NVIDIA uwsm env variables
if command -v uwsm >/dev/null 2>&1; then
    log "Creating UWSM environment configuration for NVIDIA..."
    cat <<EOF >"$HOME/.config/uwsm/env-nvidia"
export LIBVA_DRIVER_NAME=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export NVD_BACKEND=direct
export ELECTRON_OZONE_PLATFORM_HINT=auto
EOF

    if ! grep -q "env-nvidia" "$HOME/.config/uwsm/env" 2>/dev/null; then
        echo "export-include env-nvidia" >>"$HOME/.config/uwsm/env"
    fi
fi

# Enable NVIDIA KMS
CONF_FILE="/etc/modprobe.d/nvidia.conf"
SETTING="options nvidia-drm modeset=1"

if [ ! -f "$CONF_FILE" ] || ! grep -Fxq "$SETTING" "$CONF_FILE"; then
    log "Enabling NVIDIA Kernel Mode Setting (KMS)..."
    echo "$SETTING" | tee "$CONF_FILE" >/dev/null
else
    log "NVIDIA KMS already configured."
fi

# Inject NVIDIA modules into mkinitcpio for initramfs regeneration
    MK_CONF="/etc/mkinitcpio.conf"

    # Check if nvidia_drm is already in the MODULES array (even if commented out)
    if ! grep -E "^MODULES=.*nvidia_drm" "$MK_CONF" >/dev/null 2>&1 &&
        ! grep -E "^MODULES\+=\(.*\bnvidia_drm\b.*\)" "$MK_CONF" >/dev/null 2>&1; then

        # Append the new modules line
        log "Injecting NVIDIA modules into mkinitcpio..."
        echo -e "\n# Added by setup script\nMODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | tee -a "$MK_CONF" >/dev/null

        log "Regenerating initramfs (this may take a moment)..."
        mkinitcpio -P
    else
        log "NVIDIA modules already present in mkinitcpio. Skipping regeneration."
    fi
