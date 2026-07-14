{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

    brave
    stremio-linux-shell
    
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
    topgrade

    # Containerization
    flatpak

  ];
}
