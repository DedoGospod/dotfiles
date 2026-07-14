{ config, pkgs, ... }:

{
  services = {
    openssh.enable = true;
    fstrim.enable = true;
    power-profiles-daemon.enable = true;
    gnome.gnome-keyring.enable = true;
    
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

  };

  # Grouping related hardware configs
  hardware.bluetooth.enable = true;
}
