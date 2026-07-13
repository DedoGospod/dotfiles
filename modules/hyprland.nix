{ pkgs, ... }:

{
  # ============================================================================
  # System-Level Configuration (NixOS)
  # ============================================================================
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # ============================================================================
  # User-Level Configuration (Home Manager)
  # ============================================================================
  home-manager.users.dylan = { pkgs, ... }: {
    
    # Enable user-level desktop services
    services.hypridle.enable = true;
    services.hyprsunset.enable = true;
    programs.waybar.enable = true;

    # Desktop specific user utilities
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
  };
}
