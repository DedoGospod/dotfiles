{ config, pkgs, ... }:

{
  # Modules
  imports = [
    # ./modules/neovim.nix
    # ./modules/gaming.nix
    # ./modules/wol.nix
    # ./modules/kde-connect.nix
  ];

  # Settings
  nixpkgs.config.allowUnfree = true;
  home.username = "dylan";
  home.homeDirectory = "/home/dylan";
  home.stateVersion = "25.05";

  # Packages
  home.packages = with pkgs; [
    brave
    trash-cli
    sway-audio-idle-inhibit
  ];

  # Self-Management
  programs.home-manager.enable = true;
}

