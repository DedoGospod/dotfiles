#!/usr/bin/env bash

sudo pacman -S curl
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

# Restart the Nix Daemon
echo "Restarting the nix-daemon to apply new configuration..."
sudo systemctl daemon-reload
sudo systemctl restart nix-daemon
echo "✅ Nix daemon restarted."

# Give nix access to system fonts
sudo mkdir -p /etc/fonts
sudo ln -sf /etc/fonts/fonts.conf /etc/fonts/fonts.conf

# For user specific fonts
sudo mkdir -p /usr/share/fonts
sudo ln -sf /usr/share/fonts /usr/share/fonts

# Clear font cache
fc-cache -fv

echo "Log out and log back in for changes to take effect"
echo "vim into /etc/nix/nix.conf and on a new line add: experimental-features = nix-command flakes "
