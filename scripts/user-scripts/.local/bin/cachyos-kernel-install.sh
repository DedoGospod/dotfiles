#!/usr/bin/env bash

# --- Configuration ---
REPO_URL="https://mirror.cachyos.org/cachyos-repo.tar.xz"
TMP_DIR=$(mktemp -d)
ARCHIVE="$TMP_DIR/cachyos-repo.tar.xz"

# --- Error Handling & Cleanup ---
set -euo pipefail
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Downloading CachyOS repository installer..."
if ! curl -L "$REPO_URL" -o "$ARCHIVE"; then
    echo "Error: Failed to download the repository archive." >&2
    exit 1
fi

echo "==> Extracting archive..."
tar -xJf "$ARCHIVE" -C "$TMP_DIR"

# Move to the extracted directory safely
cd "$TMP_DIR/cachyos-repo"

echo "==> Starting the installation script..."
sudo -v
sudo ./cachyos-repo.sh

echo "==> Installation complete. Cleaning up temporary files..."
