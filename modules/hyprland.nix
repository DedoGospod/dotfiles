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

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      targets = [ "hyprland-session.target" ];
    };

    # Desktop specific user utilities
    home.packages = with pkgs; [
        hyprlock
        hyprpaper
        hyprshot
        hyprpolkitagent
        hyprutils
        wofi
        swaynotificationcenter
        dbus

        xdg-desktop-portal-hyprland

        xdg-desktop-portal
        xdg-desktop-portal-gtk

        qt5-

        #hyprland-guiutils
    ];
  };
}
