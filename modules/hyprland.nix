{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hypridle
    hyprlock
    hyprpaper
    hyprshot
    #hyprtoolkitagent
    #hyprland-guiutils
    hyprutils
    waybar
    wofi
    #swaync
    dbus
    hyprsunset
  ];

  services.hypridle.enable = true;
  services.hyprsunset.enable = true;

  programs.waybar.enable = true;
}
