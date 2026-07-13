{ config, pkgs, ... }:

{
  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Basic system settings
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Australia/Perth";

  # User management
  users.users.dylan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
