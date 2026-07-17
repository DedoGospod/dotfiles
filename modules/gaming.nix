{ pkgs, ... }:

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
      settings = {
        general = {
          renice = 10;
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          nv_powermizer_mode = 1;
        };
        custom = {
          start = "${pkgs.bash}/bin/bash /home/dylan/.local/bin/game-handler start";
          end = "${pkgs.bash}/bin/bash /home/dylan/.local/bin/game-handler end";
        };
      };
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
