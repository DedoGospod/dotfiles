#!/usr/bin/env zsh

### Custom Zsh Functions ###

# Automatically do an ls after each zl command
zl() {
    if [ -z "$@" ]; then
        ls -1 --color=always --group-directories-first
    else
        z "$@" && \
        ls -1 --color=always --group-directories-first
    fi;
}

zlh() {
    if [ -z "$@" ]; then
        ls -1A --color=always --group-directories-first
    else 
        z "$@" && \
        ls -1A --color=always --group-directories-first
    fi
}

# nv works for root and user files
nv() {
    if [ -z "$1" ]; then
        command nvim
        return
    fi
    
    if [ -f "$1" ] && [ ! -O "$1" ]; then
        echo "Using sudoedit for root file: $1"
        command sudoedit "$@"
    
    else
        command nvim "$@"
    fi
}

# git add + git status 
ga() {
    git add . && git status
}

# Install or Remove packages from install script
# Configuration
SCRIPT_PATH="/home/dylan/dotfiles/install-script-archlinux.sh"

install() {
    local pkg=$1
    if [[ -z "$pkg" ]]; then
        echo "Usage: install_pkg <package_name>"
        return 1
    fi

    # 1. Check Official Repos (Pacman)
    if pacman -Si "$pkg" &>/dev/null; then
        echo "Found '$pkg' in Pacman repositories..."
        sudo pacman -S --needed --noconfirm "$pkg" && \
        { grep -q "$pkg" "$SCRIPT_PATH" || sed -i "/PACMAN_PACKAGES=(/,/)/ s/)/    $pkg\n)/" "$SCRIPT_PATH"; }
        return 0
    fi

    # 2. Check AUR (using paru)
    if paru -Si "$pkg" &>/dev/null; then
        echo "Found '$pkg' in AUR..."
        paru -S --needed --noconfirm "$pkg" && \
        { grep -q "$pkg" "$SCRIPT_PATH" || sed -i "/AUR_PACKAGES=(/,/)/ s/)/    $pkg\n)/" "$SCRIPT_PATH"; }
        return 0
    fi

    # 3. Check Flatpak
    local flat_id=$(flatpak search "$pkg" | head -n 1 | awk '{print $2}')
    if [[ -n "$flat_id" ]]; then
        echo "Found '$pkg' on Flathub as $flat_id..."
        flatpak install -y flathub "$flat_id" && \
        { grep -q "$flat_id" "$SCRIPT_PATH" || sed -i "/FLATPAK_APPS=(/,/)/ s/)/    $flat_id\n)/" "$SCRIPT_PATH"; }
        return 0
    fi

    echo "Error: Package '$pkg' not found."
    return 1
}

remove() {
    local pkg=$1
    if [[ -z "$pkg" ]]; then
        echo "Usage: remove_pkg <package_name>"
        return 1
    fi

    echo "Searching for '$pkg' to remove..."

    # Remove from Pacman
    if pacman -Qi "$pkg" &>/dev/null; then
        sudo pacman -Rs --noconfirm "$pkg"
        sed -i "/$pkg/d" "$SCRIPT_PATH"
        echo "Removed $pkg from system and script."
        
    # Remove from AUR (via paru)
    elif paru -Qi "$pkg" &>/dev/null; then
        paru -Rs --noconfirm "$pkg"
        sed -i "/$pkg/d" "$SCRIPT_PATH"
        echo "Removed $pkg from AUR and script."

    # Remove from Flatpak
    elif flatpak info "$pkg" &>/dev/null; then
        flatpak uninstall -y "$pkg"
        sed -i "/$pkg/d" "$SCRIPT_PATH"
        echo "Removed $pkg from Flatpak and script."
    else
        echo "Package '$pkg' not found on system."
    fi
}
