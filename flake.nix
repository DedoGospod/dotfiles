{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    scopebuddy = {
        url = "github:HikariKnight/ScopeBuddy";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: 
  let
    sharedModules = [
      ./configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.dylan = import ./home.nix;
          backupFileExtension = "backup";
        };
      }
    ];
  in {
    nixosConfigurations = {
      # Desktop Profile
      desktop-hyprland = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = sharedModules ++ [ ./hosts/desktop.nix ];
      };

      # Virtual Machine Profile
      vm-hyprland = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = sharedModules ++ [ ./hosts/vm.nix ];
      };
    };
  };
}
