{ ... }:

{
  security.apparmor.enable = true;
  networking.firewall.enable = true;

  # Ensure necessary firmware and microcode are up to date for security
  hardware.enableAllFirmware = true;

}
