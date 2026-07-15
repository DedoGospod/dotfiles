{ lib, pkgs, ... }:

{
  # Boot configuration
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    #efiInstallAsRemovable = true; #Good for VMs
  };

  boot.kernelParams = lib.mkBefore [ 
    "amd_pstate=active" 
    "initcall_blacklist=acpi_cpufreq_init" 
  ];

  # Basic system settings
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Australia/Perth";

  # User management
  users.users.dylan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" ];
    shell = pkgs.zsh;
  };

  # Automatic garbage collection and optimization
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.optimise.automatic = true;
  systemd.timers."nix-gc".timerConfig.Persistent = true;
  systemd.timers."nix-optimise".timerConfig.Persistent = true;
}
