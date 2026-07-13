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
    services = {
        hypridle.enable = true;
        hyprpaper.enable = true;
        pyprland.enable = true;
        hyprpolkitagent.enable = true;
        hyprsunset.enable = true;
        wayland-pipewire-idle-inhibit.enable = true;
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
        hyprsunset
        waybar
        hyprlock
        hyprpaper
        hyprshot
        hyprpolkitagent
        hyprutils
        wofi
        swaynotificationcenter
        dbus
        pyprland
        wayland-pipewire-idle-inhibit


        xdg-desktop-portal-hyprland

        xdg-desktop-portal
        xdg-desktop-portal-gtk

        #hyprland-guiutils
    ];
  };
}
