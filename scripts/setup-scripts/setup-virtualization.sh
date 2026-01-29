#!/usr/bin/env bash

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

header "Configuring Virtualization"

# PACKAGE INSTALLATION ---
VIRTUALIZATION_PACKAGES=(
    qemu-full libvirt virt-manager dnsmasq iptables-nft 
    swtpm edk2-ovmf iproute2 openbsd-netcat dmidecode
)

log_task "Checking dependencies"
read -r -a MISSING_PACKAGES <<< "$(pacman -T "${VIRTUALIZATION_PACKAGES[@]}" 2>/dev/null || true)"

if [[ ${#MISSING_PACKAGES[@]} -eq 0 ]]; then
    ok
    log_task "All packages are already installed."
    ok
else
    fail
    log "Installing: ${MISSING_PACKAGES[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
fi

# KERNEL MODULES ---
CPU_VENDOR=$(grep -m 1 'vendor_id' /proc/cpuinfo | awk '{print $3}')
if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
    log_task "Loading kvm_intel"
    sudo modprobe kvm_intel
    ok
elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    log_task "Loading kvm_amd"
    sudo modprobe kvm_amd
    ok
fi
log_task "Loading vhost_net"
sudo modprobe vhost_net
ok

# USER GROUPS 
for group in libvirt kvm; do
    if getent group "$group" >/dev/null; then
        if ! id -nG "$(whoami)" | grep -qw "$group"; then
            log_task "Adding $(whoami) to $group"
            if sudo usermod -aG "$group" "$(whoami)"; then
                ok
                touch /tmp/reboot_required
            else
                fail
                error "Failed to add user to $group. Check permissions."
            fi
            touch /tmp/reboot_required
        else
            log_task "User already in $group"
            ok
        fi
    fi
done

# MODULAR SERVICE CONFIGURATION ---
# Critical: Mask monolithic libvirtd to prevent socket conflicts
log_task "Neutralizing legacy monolithic libvirtd"
sudo systemctl disable --now libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket >/dev/null 2>&1 || true
sudo systemctl mask libvirtd.service libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket >/dev/null 2>&1
ok

VIRT_SOCKETS=(
    "virtqemud.socket"
    "virtnetworkd.socket"
    "virtstoraged.socket"
    "virtnodedevd.socket"
    "virtsecret.socket"
    "virtinterfaced.socket"
)

log_task "Enabling virt sockets"
if sudo systemctl enable --now "${VIRT_SOCKETS[@]}" >/dev/null 2>&1; then
    ok
else
    # Check if they are actually active despite the exit code
    if systemctl is-active --quiet virtqemud.socket; then
        ok
        log_task "Sockets were already active."
        ok
    else
        fail
        error "Check 'systemctl status virtqemud.socket' for details."
    fi
fi

# NETWORK CONFIGURATION
log_task "Waiting for virtnetworkd readiness"
TIMEOUT=10
while ! sudo virsh uri >/dev/null 2>&1 && [ $TIMEOUT -gt 0 ]; do
    sleep 1
    ((TIMEOUT--))
done

if [ $TIMEOUT -eq 0 ]; then
    fail
    error "Libvirt failed to respond within 10 seconds."
    exit 1
fi
ok

# Define default network if missing
if ! sudo virsh net-list --all --name | grep -q "^default$"; then
    if [ -f /usr/share/libvirt/networks/default.xml ]; then
        sudo virsh net-define /usr/share/libvirt/networks/default.xml >/dev/null
        log "Defined 'default' network from template."
    else
        error "Default network XML not found."
    fi
fi

# Ensure active and autostart
if ! sudo virsh net-list --all | grep -q "default.*active"; then
    sudo virsh net-start default >/dev/null
    log "Started 'default' network."
fi

if [[ $(sudo virsh net-info default | grep -i 'Autostart' | awk '{print $2}') == "no" ]]; then
    sudo virsh net-autostart default >/dev/null
    log "Enabled autostart for 'default' network."
fi

# FINAL VERIFICATION
log_task "Verifying connection to qemu:///system verified"
if sudo virsh uri | grep -q "qemu:///system"; then
    ok
else
    fail
    error "Could not verify connection to qemu:///system."
    exit 1
fi
