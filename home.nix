{ config, pkgs, ... }:

{
  imports = [
    ./modules/user-packages.nix
    ./modules/shell.nix
    ./modules/user-services.nix
    ./modules/files.nix

    # --- CUSTOM MODULES ---
    ./modules/neovim.nix
  ];

  home = {
    username = "dylan";
    homeDirectory = "/home/dylan";
    stateVersion = "25.05";
  };

}
