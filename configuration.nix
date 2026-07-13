{ config, pkgs, ... }:

{
    imports = [
      ./hardware-configuration.nix

      # --- DESKTOP MODULES ---
      ./modules/hyprland.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Perth";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

    users.users.dylan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

    environment.systemPackages = with pkgs; [
    vim
    git

  ];

  services = {
    openssh.enable = true;
    fstrim.enable = true;
  };

  networking = {
    networkmanager.enable = true;
  };

  security = {
    apparmor.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";

}
