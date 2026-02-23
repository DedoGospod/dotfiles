#!/usr/bin/env bash

set -e
set -o pipefail

echo "--- Detecting System Capabilities ---"
/lib/ld-linux-x86-64.so.2 --help | grep "supported"

echo "--- Downloading CachyOS Repo Helper ---"
WORKDIR=$(mktemp -d)
cd "$WORKDIR"

curl -L https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz

echo "--- Extracting and Installing ---"
tar xvf cachyos-repo.tar.xz
cd cachyos-repo

sudo -v
sudo ./cachyos-repo.sh

echo "--- Cleaning up ---"
rm -rf "$WORKDIR"

# Sync repos
sudo pacman -Syu --needed --noconfirm 

# CachyOS kernel
PACMAN_PACKAGES=()

# Prompt the user
read -r -p "$(echo -e "  ${YELLOW}??${NC} Install CachyOS kernel? (y/N): ")" install_cachy_kernel

# If yes, add the strings directly to the main array
if [[ "$install_cachy_kernel" =~ ^[Yy]$ ]]; then 
    PACMAN_PACKAGES+=("linux-cachyos" "linux-cachyos-headers")
fi

echo "Installing Official Packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
