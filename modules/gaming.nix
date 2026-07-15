{ ... }:

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
    gamemode = {
      enable = true; 
      enableRenice = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
      enableWsi = true;
    };

  };

  # GPU specific hardware configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ============================================================================
  # User-Level Configuration (Home Manager)
  # ============================================================================
  home-manager.users.dylan = { pkgs,... }: {
    
    # User-specific gaming utilities
    home.packages = with pkgs; [
      protonup-qt
      mangohud
    ];
  };
}
