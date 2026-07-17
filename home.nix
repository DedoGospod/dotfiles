{ ... }:

{
  imports = [
    ./home/packages.nix
    ./home/services.nix
    ./home/dotfiles.nix
    ./home/xdg-setup.nix
    ./home/theme.nix
  ];

  home = {
    username = "dylan";
    homeDirectory = "/home/dylan";
    stateVersion = "26.05";
  };
}
