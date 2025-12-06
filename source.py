import decman
from decman import File , Directory
# --- Core Pacman Packages and Optional Groups ---
decman.packages += [
    # Core Desktop
    "hyprland", "hypridle", "hyprlock", "hyprpaper", "hyprshot", "hyprpolkitagent",
    "hyprland-guiutils", "hyprutils", "uwsm", "waybar", "wofi", "swaync", "dbus", "wlsunset",

    # Portals & Theming
    "xdg-desktop-portal", "xdg-desktop-portal-gtk", "xdg-desktop-portal-hyprland",
    "qt5-wayland", "qt6-wayland", "qt6ct", "gnome-themes-extra",

    # Apps & Utils
    "kitty", "neovim", "nautilus", "yazi", "mpv", "fastfetch", "btop", "gnome-disk-utility",
    "obsidian", "pavucontrol", "gnome-keyring", "seahorse", "rsync", "keepassxc",

    # Shell & CLI
    "zsh", "zsh-completions", "zsh-syntax-highlighting", "zsh-autosuggestions", "starship",
    "fzf", "zoxide", "fd", "tmux", "stow", "bat", "eza", "ripgrep", "ncdu", "trash-cli", "man-db",

    # Network & Services
    "networkmanager", "bluez", "bluez-utils", "pipewire", "wireplumber", "tlp", "cronie",

    # Maintenance
    "reflector", "timeshift", "ffmpeg", "ffmpegthumbnailer",

    # Containerization
    "flatpak",

    # Kernel & Headers
    "linux-headers", "linux-zen", "linux-zen-headers",

    # Fonts
    "ttf-cascadia-code-nerd", "ttf-ubuntu-font-family", "ttf-font-awesome",
    "ttf-dejavu", "ttf-liberation", "ttf-croscore", "noto-fonts", "noto-fonts-cjk", "noto-fonts-emoji",
    
    # NVIDIA_PACKAGES (Optional Group)
    "libva-nvidia-driver", "nvidia-open-dkms", "nvidia-utils", "lib32-nvidia-utils", "nvidia-settings", "egl-wayland",
    
    # GAMING_PACKAGES (Optional Group)
    "gamemode", "gamescope", "mangohud",
    
    # NEOVIM_DEPS (Optional Group)
    "npm", "nodejs", "unzip", "clang", "go", "shellcheck", "zig", "luarocks", "dotnet-sdk", "cmake", "gcc", "imagemagick",
    
    # WAKEONLAN_PACKAGES (Optional Group)
    "wol", "ethtool"
]

# --- AUR Packages ---
decman.aur_packages += [
    "timeshift-autosnap",
    "wayland-pipewire-idle-inhibit",
    "brave-bin",
    "nvibrant-bin",
    "pyprland",
    "decman"
]

# --- Configuration Files (Kept from your original script) ---
# Inline
decman.files["/home/dylan/.zshrc"] = File(
    source_file="./zsh/.zshrc", 
    owner="dylan"
)

# Declare a whole directory
decman.directories["/home/dylan/.config/nvim"] = Directory(source_directory="~/dotfiles/nvim",
                                                          owner="dylan")

# Ensure that a systemd unit is enabled.
decman.enabled_systemd_units = [
    # --- Essential System Services ---
    "NetworkManager.service",
    "bluetooth.service",
    "cronie.service",
    "tlp.service",
    "grub-btrfsd.service",
    "wol.service",

    # --- User-Level Services ---
    "hypridle.service",
    "hyprpaper.service",
    "waybar.service",
    "pyprland.service",
    "hyprpolkitagent.service",
    "wayland-pipewire-idle-inhibit.service",
    "swaync.service",
    "wlsunset.service",
    "easyeffects.service",
    "obs.service",
]
