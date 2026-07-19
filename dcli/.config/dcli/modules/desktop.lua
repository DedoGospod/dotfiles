local packages = {
    -- Window Manager
    "hyprland", "hypridle", "hyprlock", "hyprpaper", "hyprshot", "hyprpolkitagent", "hyprland-guiutils",
    "hyprutils", "uwsm", "waybar", "wofi", "swaync", "dbus", "hyprsunset", "pyprland",

    -- Portals
    "xdg-desktop-portal-hyprland", "xdg-desktop-portal", "xdg-desktop-portal-gtk",

    -- Theme
    "qt5-wayland", "qt6-wayland", "qt6ct", "gnome-themes-extra",

    -- Fonts
    "ttf-cascadia-code-nerd", "ttf-ubuntu-font-family", "ttf-font-awesome",
    "ttf-dejavu", "ttf-liberation", "ttf-croscore", "noto-fonts", "noto-fonts-cjk",
    "noto-fonts-emoji",

    -- Apps & Utils
    "neovim", "nautilus", "yazi", "mpv", "imv", "fastfetch", "btop", "gnome-disk-utility",
    "obsidian", "pavucontrol", "ffmpeg", "ffmpegthumbnailer", "pipewire", "wireplumber",
    "syncthing",

    -- Shell & CLI
    "kitty", "zsh", "zsh-completions", "zsh-syntax-highlighting", "zsh-autosuggestions", "starship",
    "fzf", "zoxide", "fd", "tmux", "stow", "bat", "eza", "ripgrep", "trash-cli",

    -- Bluetooth
    "bluez", "bluez-utils",

    -- Maintnence
    "pacman-contrib", "ncdu", "rsync", "dracut",

    -- Power Management
    "power-profiles-daemon"
}

return {
    description = "Hyprland specific packages",
    packages = packages,
}
