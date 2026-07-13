{ config, pkgs, ... }:

let
  linkDot = repoPath: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${repoPath}";
  };
in {

  imports = [
    ./modules/neovim.nix
  ];

  home.packages = with pkgs; [
    # Core desktop
    hypridle
    hyprlock
    hyprpaper
    hyprpolkitagent
    hyprutils
    waybar
    dbus
    hyprsunset

    # Shell & CLI
    kitty
    zsh
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
    starship
    fzf
    zoxide
    fd
    tmux
    bat
    eza
    ripgrep
    trash-cli

    # Theme
    #qt6ct
    gnome-themes-extra

    # Apps & Utils
    nautilus
    yazi
    mpv
    imv
    fastfetch
    btop
    gnome-disk-utility
    obsidian
    pavucontrol
    ffmpeg
    ffmpegthumbnailer
    
    # Security
    gnome-keyring
    seahorse
    keepassxc

    # Bluetooth
    bluez
    bluez-tools

    # Maintnence
    ncdu
    rsync
    rsnapshot
    dracut
    topgrade

    # Power management
    power-profiles-daemon
    #ananicy-cpp

    # Containerization
    flatpak
  ];

  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
  };

  # Dotfiles
  home.file = {
    # Directories
    ".config/backgrounds" = linkDot "backgrounds/.config/backgrounds";
    ".config/fastfetch"   = linkDot "fastfetch/.config/fastfetch";
    ".config/hypr"        = linkDot "hypr/.config/hypr";
    ".config/pypr"        = linkDot "hypr/.config/pypr";
    ".config/kitty"       = linkDot "kitty/.config/kitty";
    ".config/MangoHud"    = linkDot "mangohud/.config/MangoHud";
    ".config/mpv"         = linkDot "mpv/.config/mpv";
    ".config/nvim"        = linkDot "nvim/.config/nvim";
    ".config/projects"    = linkDot "projects/Projects";
    ".config/scopebuddy"  = linkDot "scopebuddy/.config/scopebuddy";
    ".config/swaync"      = linkDot "swaync/.config/swaync";
    ".config/tmux"        = linkDot "tmux/.config/tmux";
    ".config/autostart"   = linkDot "uwsm/.config/autostart";
    ".config/uwsm"        = linkDot "uwsm/.config/uwsm";
    ".config/waybar"      = linkDot "waybar/.config/waybar";
    ".config/wofi"        = linkDot "wofi/.config/wofi";
    ".config/yazi"        = linkDot "yazi/.config/yazi";
    ".config/zsh"         = linkDot "zsh/.config/zsh";
    ".config/wayland-pipewire-idle-inhibit" = linkDot "wayland-pipewire-idle-inhibit/.config/wayland-pipewire-idle-inhibit";

    # Individual files
    ".zshenv"               = linkDot "zsh/.zshenv";
    ".config/starship.toml" = linkDot "starship/.config/starship.toml";
    ".config/topgrade.toml" = linkDot "topgrade/.config/topgrade.toml";
    ".config/kwalletrc"     = linkDot "kwalletrc/.config/kwalletrc";
  };
}
