#{ config, pkgs, ... }:
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/packages.nix
    ./modules/system.nix
    ./modules/services.nix
    ./modules/security.nix

    ./modules/virtualization.nix

    # --- DESKTOP MODULES
    ./modules/hyprland.nix
  ];

  # Global settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
}
