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

  security.pam.services.hyprlock = {};

  # ============================================================================
  # User-Level Configuration (Home Manager)
  # ============================================================================
  home-manager.users.dylan = { pkgs, ... }: {
    
    # Enable user-level desktop services
    services = {
        hypridle.enable = true;
        hyprpaper.enable = true;
        hyprpolkitagent.enable = true;
        hyprsunset.enable = true;
        #pyprland.enable = true;
        #wayland-pipewire-idle-inhibit.enable = true;
    };

    programs = {
        waybar = {
            enable = true;
            systemd.enable = true;
        };
    };

    # Desktop specific user utilities
    home.packages = with pkgs; [
        hypridle
        hyprpaper
        hyprpolkitagent
        hyprsunset
        hyprshot
        hyprlock
        hyprutils
        wofi
        swaynotificationcenter
        pyprland
        wayland-pipewire-idle-inhibit
        #hyprland-guiutils
        #glib
    ];
  };
}
