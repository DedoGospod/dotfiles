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

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--autopower" ];
};

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules; 
  };

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    ubuntu-classic
    font-awesome
    dejavu_fonts
    liberation_ttf
    croscore-fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}
