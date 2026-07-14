{ config, pkgs, ... }:

{
  imports = [
    ./home/packages.nix
    ./home/shell.nix
    ./home/services.nix
    ./home/files.nix
    ./home/xdg-setup.nix

    # --- CUSTOM MODULES ---
    ./modules/neovim.nix
  ];

  home = {
    username = "dylan";
    homeDirectory = "/home/dylan";
    stateVersion = "25.05";
  };

}
