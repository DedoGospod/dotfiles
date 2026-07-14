{ pkgs, ... }:
{
  # Gaming specific optimizations
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
    mangohud.enable = true;
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    protonup-qt
  ];

  # GPU specific hardware configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
