{ pkgs, ... }:

{
  home.packages = with pkgs; [
  # Shell & CLI
    kitty
    starship
    fzf
    zoxide
    fd
    tmux
    bat
    eza
    ripgrep
    trash-cli

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
    keepassxc

    # Bluetooth
    bluez
    bluez-tools

    # Maintnence
    ncdu
    rsync
    rsnapshot
    topgrade
  ];
}
