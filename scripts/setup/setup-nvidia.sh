#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper Functions
header() { echo -e "\n${BLUE}==== $1 ====${NC}"; }
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

log_task() { echo -ne "${GREEN}[INFO]${NC} $1... "; }
ok() { echo -e "${GREEN}Done.${NC}"; }
fail() { echo -e "${RED}Failed.${NC}"; }

# NVIDIA Configuration Block
header "NVIDIA SETUP"

NVIDIA_PACKAGES=(libva-nvidia-driver nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland)
MISSING_PACKAGES=()

for pkg in "${NVIDIA_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    log_task "All NVIDIA packages are already installed."
    ok
else
    log_task "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
    ok
fi

# Enable NVIDIA KMS
CONF_FILE="/etc/modprobe.d/nvidia.conf"
SETTING="options nvidia-drm modeset=1"

if [ ! -f "$CONF_FILE" ] || ! grep -Fxq "$SETTING" "$CONF_FILE"; then
    log_task "Enabling NVIDIA Kernel Mode Setting (KMS)..."
    if echo "$SETTING" | sudo tee "$CONF_FILE" >/dev/null; then ok; else fail; fi
else
    log_task "NVIDIA KMS already configured."
    ok
fi

# Inject NVIDIA modules into mkinitcpio for initramfs regeneration
MK_CONF="/etc/mkinitcpio.conf"

# Check if nvidia_drm is already in the MODULES array (even if commented out)
if ! grep -E "^MODULES=.*nvidia_drm" "$MK_CONF" >/dev/null 2>&1 &&
    ! grep -E "^MODULES\+=\(.*\bnvidia_drm\b.*\)" "$MK_CONF" >/dev/null 2>&1; then

    # Append the new modules line
    log_task "Injecting NVIDIA modules into mkinitcpio"
    if echo -e "\n# Added by setup script\nMODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee -a "$MK_CONF" >/dev/null; then ok; else fail; fi

    log_task "Regenerating initramfs (this may take a moment)..."
    if sudo mkinitcpio -P; then ok; else fail; fi
else
    log_task "NVIDIA modules already present in mkinitcpio"
    ok
fi
