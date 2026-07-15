#{ config, pkgs, ... }:
{ ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/security.nix
	
    #./modules/nvidia.nix

    #./modules/gaming.nix
    #./modules/virtualization.nix

    # --- DESKTOP MODULES
    ./modules/hyprland.nix
  ];

  # Global settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";

}
