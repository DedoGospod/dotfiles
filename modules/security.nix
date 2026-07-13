{ config, pkgs, ... }:

{
  security = {
    apparmor.enable = true;
  };
  
  # Ensure necessary firmware and microcode are up to date for security
  hardware.enableAllFirmware = true;
}
