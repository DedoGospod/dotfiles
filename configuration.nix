#{ config, pkgs, ... }:
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/packages.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/security.nix
	
    # Drivers
    ./modules/nvidia.nix

    #./modules/virtualization.nix

    # --- DESKTOP MODULES
    ./modules/hyprland.nix
  ];

  # Global settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";

}
