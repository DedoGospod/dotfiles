{ pkgs, inputs, ... }:

{
  # ============================================================================
  # System-Level Configuration (NixOS)
  # ============================================================================
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
    };
    
    # Allows games to request a high-performance CPU governor
    #gamemode.enable = true; 

    gamescope.enable = true;
  };

  # GPU specific hardware configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ============================================================================
  # User-Level Configuration (Home Manager)
  # ============================================================================
  home-manager.users.dylan = { pkgs, ... }: {
    
    # User-specific gaming utilities
    home.packages = [
      inputs.scopebuddy.packages.${pkgs.system}.default
      pkgs.protonup-qt
      pkgs.mangohud
    ];
  };
}
