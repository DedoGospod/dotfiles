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

# Kernel check
GENERIC_KERNELS=$(pacman -Qq | grep -E '^linux(-zen|-lts|-hardened|-rt)?$' || true)
CACHY_KERNELS=$(pacman -Qq | grep -E '^linux-cachyos(-bin|-rc|-lts)?$' || true)

if [[ -n "$GENERIC_KERNELS" ]]; then
    DRIVER_PKG="nvidia-open-dkms"
    log "Generic/Zen kernel(s) detected: $(echo "$GENERIC_KERNELS" | tr '\n' ' ')"
    log_task "Using $DRIVER_PKG to ensure compatibility across all kernels."
    ok
elif [[ -n "$CACHY_KERNELS" ]]; then
    DRIVER_PKG="linux-cachyos-nvidia-open"
    log_task "Only CachyOS kernel(s) detected. Using optimized modules: $DRIVER_PKG"
    ok
else
    # Fallback if somehow no kernel is detected by the regex
    DRIVER_PKG="nvidia-open-dkms"
    warn "No standard kernel naming matched. Defaulting to DKMS for safety."
fi

# Package list
NVIDIA_PACKAGES=("$DRIVER_PKG" nvidia-settings nvidia-utils libva-nvidia-driver lib32-nvidia-utils egl-wayland)
MISSING_PACKAGES=()

# Check if packages exist on system
for pkg in "${NVIDIA_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

# Install any missing packages
if [[ ${#MISSING_PACKAGES[@]} -eq 0 ]]; then
    log_task "All NVIDIA packages are already installed."
    ok
else
    log_task "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
    touch /tmp/reboot_required
    ok
fi

# Enable NVIDIA KMS
CONF_FILE="/etc/modprobe.d/nvidia.conf"
SETTING="options nvidia-drm modeset=1"

if [[ ! -f "$CONF_FILE" ]] || ! grep -Fxq "$SETTING" "$CONF_FILE"; then
    log_task "Enabling NVIDIA Kernel Mode Setting (KMS)..."
    if echo "$SETTING" | sudo tee "$CONF_FILE" >/dev/null; then 
        touch /tmp/reboot_required
        ok 
    else 
        fail 
    fi
else
    log_task "NVIDIA KMS already configured."
    ok
fi

# Inject NVIDIA modules into mkinitcpio for initramfs regeneration
MK_CONF="/etc/mkinitcpio.conf"

# Check if nvidia_drm is already in the MODULES array (even if commented out)
if ! grep -E "^MODULES=.*nvidia_drm" "$MK_CONF" >/dev/null 2>&1 &&
    ! grep -E "^MODULES\+=\(.*\bnvidia_drm\b.*\)" "$MK_CONF" >/dev/null 2>&1; then

    log_task "Injecting NVIDIA modules into mkinitcpio"
    if echo -e "\n# Added by setup script\nMODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee -a "$MK_CONF" >/dev/null; then 
        ok 
    else 
        fail 
    fi

    log_task "Regenerating initramfs (this may take a moment)..."
    if sudo mkinitcpio -P; then 
        touch /tmp/reboot_required
        ok
    else 
        fail
    fi
else
    log_task "NVIDIA modules already present in mkinitcpio"
    ok
fi
