import decman
import decman.config
from decman import Directory, File

USER = "dylan"
HOME = f"/home/{USER}"
DOTDIR = f"{HOME}/dotfiles"

decman.config.enable_flatpak = True

# --- SYSTEM & KERNEL ---
KERNEL = [
    "linux", "linux-headers", "linux-zen", "linux-zen-headers",
    "linux-firmware", "amd-ucode", "base", "base-devel"
]

SYSTEM_UTILS = [
    "btrfs-progs", "grub", "efibootmgr", "os-prober", "grub-btrfs",
    "ntfs-3g", "zram-generator", "sudo", "wget", "git", "rsync",
    "paru", "man-db"
]

# --- AUDIO & NETWORK ---
AUDIO = [
    "pipewire", "pipewire-pulse", "pipewire-alsa", "pipewire-jack", 
    "wireplumber", "libpulse", "gst-plugin-pipewire", "pavucontrol"
]

NETWORK = [
    "networkmanager", "bluez", "bluez-utils", "syncthing", 
    "kdeconnect", "cronie"
]

# --- DISPLAY & DESKTOP ---
HYPRLAND = [
    "hyprland", "hypridle", "hyprlock", "hyprpaper", "hyprshot", 
    "hyprpolkitagent", "hyprland-guiutils", "hyprutils", "uwsm", 
    "waybar", "wofi", "swaync", "dbus", "wlsunset"
]

THEMING_PORTALS = [
    "xdg-desktop-portal", "xdg-desktop-portal-gtk", "xdg-desktop-portal-hyprland",
    "qt5-wayland", "qt6-wayland", "qt6ct", "gnome-themes-extra"
]

# --- APPLICATIONS & TOOLS ---
APPS = [
    "kitty", "nautilus", "yazi", "mpv", "obsidian", "keepassxc",
    "gnome-disk-utility", "gnome-keyring", "seahorse", "fastfetch", "btop"
]

MAINTENANCE = [
    "reflector", "timeshift", "ffmpeg", "ffmpegthumbnailer", 
    "flatpak", "power-profiles-daemon"
]

FONTS = [
    "ttf-cascadia-code-nerd", "ttf-ubuntu-font-family", "ttf-font-awesome",
    "ttf-dejavu", "ttf-liberation", "ttf-croscore", "noto-fonts", 
    "noto-fonts-cjk", "noto-fonts-emoji", "woff2-font-awesome"
]

NVIDIA = [
    "libva-nvidia-driver", "nvidia-open-dkms", "nvidia-utils", 
    "lib32-nvidia-utils", "nvidia-settings", "egl-wayland"
]

NEOVIM = [
    "neovim", "npm", "nodejs", "unzip", "clang", "go", "shellcheck", 
    "zig", "luarocks", "dotnet-sdk", "cmake", "gcc", "imagemagick", "rustup"
]

GAMING = [
    "steam", "gamemode", "gamescope", "mangohud"
]

WOL = [
    "wol", "ethtool"
]

SHELL_CLI = [
    "zsh", "zsh-completions", "zsh-syntax-highlighting", "zsh-autosuggestions", 
    "starship", "fzf", "zoxide", "fd", "tmux", "stow", "bat", "eza", 
    "ripgrep", "ncdu", "trash-cli"
]

decman.packages += (
    KERNEL + 
    SYSTEM_UTILS + 
    AUDIO + 
    NETWORK + 
    HYPRLAND + 
    THEMING_PORTALS + 
    APPS + 
    MAINTENANCE + 
    FONTS + 
    NVIDIA + 
    NEOVIM + 
    GAMING + 
    WOL + 
    SHELL_CLI
)

# Declare installed aur packages
decman.aur_packages += [
    "decman", "timeshift-autosnap", "wayland-pipewire-idle-inhibit", "brave-bin", "nvibrant-bin",
    "pyprland", "obs-vkcapture",
]

# System-wide packages (accessible by all users)
decman.flatpak_packages += [
    "com.github.tchx84.Flatseal",
    "io.github.ebonjaeger.bluejay",
    "com.github.wwmm.easyeffects",

]

# User-specific packages
decman.flatpak_user_packages[USER] = [
    "it.mijorus.gearlever",
    "com.stremio.Stremio",
    "com.usebottles.bottles",
    "com.vysp3r.ProtonPlus",
    
]

# Declare configuration files
decman.files["/etc/vconsole.conf"] = File(content="KEYMAP=us")
decman.files["/etc/systemd/system/wol.service"] = File(source_file=f"{DOTDIR}/etc/wol.service")
decman.files["/etc/pacman.conf"] = File(source_file=f"{DOTDIR}/etc/pacman.conf")

decman.files[f"{HOME}/.config/starship.toml"] = File(source_file=f"{DOTDIR}/starship/.config/starship.toml")
decman.files[f"{HOME}/.config/kwalletrc"] = File(source_file=f"{DOTDIR}/kwalletrc/.config/kwalletrc")
decman.files[f"{HOME}/.gtkrc-2.0"] = File(source_file=f"{DOTDIR}/theme/.gtkrc-2.0")
decman.files[f"{HOME}/.zprofile"] = File(source_file=f"{DOTDIR}/zsh/.zprofile")
decman.files[f"{HOME}/.zshrc"] = File(source_file=f"{DOTDIR}/zsh/.zshrc")

# Declare a whole directory
decman.directories[f"{HOME}/.config/backgrounds"] = Directory(source_directory=f"{DOTDIR}/backgrounds/.config/backgrounds", owner=USER)
decman.directories[f"{HOME}/.config/fastfetch"] = Directory(source_directory=f"{DOTDIR}/fastfetch/.config/fastfetch", owner=USER)
decman.directories[f"{HOME}/.config/hypr"] = Directory(source_directory=f"{DOTDIR}/hypr/.config/hypr", owner=USER)
decman.directories[f"{HOME}/.config/kitty"] = Directory(source_directory=f"{DOTDIR}/kitty/.config/kitty", owner=USER)
decman.directories[f"{HOME}/.config/MangoHud"] = Directory(source_directory=f"{DOTDIR}/mangohud/.config/MangoHud", owner=USER)
decman.directories[f"{HOME}/.config/mpv"] = Directory(source_directory=f"{DOTDIR}/mpv/.config/mpv", owner=USER)
decman.directories[f"{HOME}/.config/nvim"] = Directory(source_directory=f"{DOTDIR}/nvim/.config/nvim", owner=USER)
decman.directories[f"{HOME}/.config/swaync"] = Directory(source_directory=f"{DOTDIR}/swaync/.config/swaync", owner=USER)
decman.directories[f"{HOME}/.config/systemd"] = Directory(source_directory=f"{DOTDIR}/systemd-user/.config/systemd", owner=USER)
decman.directories[f"{HOME}/.config/gtk-3.0"] = Directory(source_directory=f"{DOTDIR}/theme/.config/gtk-3.0", owner=USER)
decman.directories[f"{HOME}/.config/gtk-4.0"] = Directory(source_directory=f"{DOTDIR}/theme/.config/gtk-4.0", owner=USER)
decman.directories[f"{HOME}/.config/qt5ct"] = Directory(source_directory=f"{DOTDIR}/theme/.config/qt5ct", owner=USER)
decman.directories[f"{HOME}/.config/qt6ct"] = Directory(source_directory=f"{DOTDIR}/theme/.config/qt6ct", owner=USER)
decman.directories[f"{HOME}/.config/tmux"] = Directory(source_directory=f"{DOTDIR}/tmux/.config/tmux", owner=USER)
decman.directories[f"{HOME}/.config/autostart"] = Directory(source_directory=f"{DOTDIR}/uwsm-autostart/.config/autostart", owner=USER)
decman.directories[f"{HOME}/.config/waybar"] = Directory(source_directory=f"{DOTDIR}/waybar/.config/waybar", owner=USER)
decman.directories[f"{HOME}/.config/wayland-pipewire-idle-inhibit"] = Directory(source_directory=f"{DOTDIR}/wayland-pipewire-idle-inhibit/.config/wayland-pipewire-idle-inhibit", owner=USER)
decman.directories[f"{HOME}/.config/wofi"] = Directory(source_directory=f"{DOTDIR}/wofi/.config/wofi", owner=USER)
decman.directories[f"{HOME}/.config/yazi"] = Directory(source_directory=f"{DOTDIR}/yazi/.config/yazi", owner=USER)
decman.directories[f"{HOME}/.config/zsh"] = Directory(source_directory=f"{DOTDIR}/zsh/.config/zsh", owner=USER)

# Ensure that a systemd unit is enabled.
decman.enabled_systemd_units += [

    # System Services
    "cronie.service",
    "bluetooth.service",
    "wol.service",
    "power-profiles-daemon.service",
    "grub-btrfsd.service",
]

# User specific units
# decman.systemd.enabled_user_units.setdefault(USER, set()).update({
    # "syncthing.service",
    # "hypridle.service",
    # "hyprpaper.service",
    # "waybar.service",
    # "pyprland.service",
    # "hyprpolkitagent.service",
    # "wlsunset.service",
    # "swaync.service",
    # "wayland-pipewire-idle-inhibit.service",
    # "easyeffects.service",
    # "obs.service",
# })

# Added to ignored_packages to prevent 'failed to set explicit'
decman.ignored_packages += [
    "base", 
    "base-devel", 
    "linux", 
    "linux-zen",
    "linux-firmware",
    "ttf-font-awesome",
    "woff2-font-awesome",
    "paru",

]

# decman.aur.ignored_packages |= {
    # "paru",
# }


# Packages installed via helper script
