#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail
sudo -v

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

# Flag to track if group changes occurred
CHANGES_MADE=false


# Setup virtualization
header "Configuring Virtualization"

# --- PACKAGE INSTALLATION SECTION ---
VIRTUALIZATION_PACKAGES=(qemu-full libvirt virt-manager dnsmasq bridge-utils)
MISSING_PACKAGES=()

for pkg in "${VIRTUALIZATION_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    log_task "All virtualization packages are already installed."
    ok
else
    log_task "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
    ok
fi
# ----------------------------------------

# Add user to groups
for group in libvirt kvm; do
    if getent group "$group" >/dev/null; then
        if groups "$(whoami)" | grep &>/dev/null "\b$group\b"; then
            log_task "User already in $group group"
            ok
        else
            log_task "Adding $(whoami) to $group group"
            if sudo usermod -aG "$group" "$(whoami)"; then
                CHANGES_MADE=true
                ok
            else
                fail
            fi
        fi
    fi
done

# Enable and start libvirtd
if systemctl is-active --quiet libvirtd; then
    log_task "libvirtd is already running"
    ok
else
    log_task "Enabling and starting libvirtd"
    if sudo systemctl enable --now libvirtd &>/dev/null; then
        ok
    else
        fail
    fi
fi

# Wait for the socket to be ready
SOCKET_READY=false
for _ in {1..5}; do
    if sudo virsh -c qemu:///system list --all >/dev/null 2>&1; then
        SOCKET_READY=true
        break
    fi
    sleep 1
done

if [ "$SOCKET_READY" = false ]; then
    fail
fi

# Robust check for the 'default' network status
NETWORK_INFO=$(sudo virsh -c qemu:///system net-info default 2>/dev/null || true)

if echo "$NETWORK_INFO" | grep -qiE "Active:\s+yes"; then
    log_task "Default network already active"
    ok
else
    log_task "Activating default network"
    sudo virsh -c qemu:///system net-autostart default &>/dev/null || true
    
    if sudo virsh -c qemu:///system net-start default &>/dev/null; then
        ok
    else
        if sudo virsh -c qemu:///system net-info default | grep -qiE "Active:\s+yes"; then
            ok
        else
            fail
        fi
    fi
fi

success "Virtualization setup complete!"

# Only show warning if changes were actually made
if [ "$CHANGES_MADE" = true ]; then
    warn "Note: You must log out and back in for group changes to take effect."
fi
