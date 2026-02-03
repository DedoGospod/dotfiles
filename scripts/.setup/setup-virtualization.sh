#!/usr/bin/env bash

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper Functions
header()  { echo -e "\n${BLUE}==== $1 ====${NC}"; }
log()     { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

log_task() { echo -ne "${GREEN}[INFO]${NC} $1... "; }
ok()       { echo -e "${GREEN}Done.${NC}"; }
fail()     { echo -e "${RED}Failed.${NC}"; }

# Package list
PACMAN_PACKAGES=(qemu-full virt-manager dnsmasq swtpm)
MISSING_PACKAGES=()

# Check if packages exist on system
for pkg in "${PACMAN_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

# Install any missing packages
if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    log_task "All Virtualization packages are already installed"
    ok
else
    log_task "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
    touch /tmp/reboot_required
    ok
fi

# Add user to libvirt group
group="libvirt"
if id -nG "$USER" | grep -qw "$group"; then
    log_task "User already in $group"
    ok
else
    log_task "Adding $USER to $group"
    if sudo usermod -aG "$group" "$USER"; then
        touch /tmp/reboot_required
        ok
    else
        error "Failed to add user to group."
        exit 1
    fi
fi

# Enable services 
services=("libvirtd.service" "libvirtd.socket")
for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc"; then
        log_task "$svc is already running"
        ok
    else
        log_task "Starting $svc..."
        sudo systemctl enable --now "$svc"
        ok
    fi
done

# Network start
net="default"
if ! sudo virsh net-list --all | grep -q "$net"; then
    log_task "Creating default network from template..."
    sudo virsh net-define /etc/libvirt/qemu/networks/default.xml
    ok
fi

# Start default network if its down
sudo virsh net-start "$net" 2>/dev/null

# Set default network to autostart
sudo virsh net-autostart "$net" 2>/dev/null
