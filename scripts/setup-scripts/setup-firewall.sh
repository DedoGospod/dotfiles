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

# --- FIREWALL CONFIGURATION ---
header "Firewall Configuration"

# --- PACKAGE INSTALLATION SECTION ---
FIREWALL_PACKAGES=(ufw)
MISSING_PACKAGES=()

for pkg in "${FIREWALL_PACKAGES[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    log_task "All firewall packages are already installed."
    ok
else
    log_task "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
    ok
fi

if command -v ufw &>/dev/null; then

    # Get the current status and policies to check against
    UFW_STATUS=$(sudo ufw status verbose)

    # Detailed check: Status, Policies, and Ports
    if echo "$UFW_STATUS" | grep -q "Status: active" &&
        echo "$UFW_STATUS" | grep -qE "Default:\s+deny\s+\(incoming\),\s+allow\s+\(outgoing\)" &&
        echo "$UFW_STATUS" | grep -qE "22/tcp\s+LIMIT\s+IN" &&
        echo "$UFW_STATUS" | grep -qE "80/tcp\s+ALLOW\s+IN" &&
        echo "$UFW_STATUS" | grep -qE "443/tcp\s+ALLOW\s+IN"; then
        log_task "UFW already configured"
        ok
    else
        # Re-apply configuration if any of the above fails
        log_task "Applying UFW default policies"
        if sudo ufw default deny incoming &>/dev/null &&
            sudo ufw default allow outgoing &>/dev/null; then
            ok
        else
            fail
        fi

        # Baseline configuration
        log_task "Configuring UFW port rules"
        if sudo ufw limit 22/tcp &>/dev/null &&
            sudo ufw allow 80/tcp &>/dev/null &&
            sudo ufw allow 443/tcp &>/dev/null; then
            ok
        else
            fail
        fi

        # --- KDE Connect Prompt ---
        echo -ne "${YELLOW}[PROMPT]${NC} Do you want to allow KDE Connect ports (1714-1764)? (y/N): "
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            log_task "Configuring KDE Connect ports"
            if sudo ufw allow 1714:1764/udp &>/dev/null &&
               sudo ufw allow 1714:1764/tcp &>/dev/null; then
                ok
            else
                fail
            fi
        fi
        # -------------------------------

        log_task "Enabling UFW"

        # Enable system service
        sudo systemctl enable ufw.service &>/dev/null

        # Enable firewall rules
        if echo "y" | sudo ufw enable &>/dev/null; then
            ok
            success "Firewall is active and configured."
        else
            fail
            error "Could not enable UFW."
        fi
    fi
else
    warn "UFW is not installed on this system."
    error "Firewall configuration skipped."
fi
