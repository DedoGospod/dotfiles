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
  home-manager.users.dylan = { pkgs, inputs, ... }: 

  {
    # User-specific gaming utilities
    home.packages = [
      pkgs.protonup-qt
      pkgs.mangohud
      inputs.scopebuddy.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
