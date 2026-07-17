{ pkgs,... }:

{
  services = {
    power-profiles-daemon.enable = true;
    gnome.gnome-keyring.enable = true;
    flatpak.enable = true;

    fstrim = {
      enable = true;
      inverval = "weekly";
    };

    openssh = {
      enable = true;
      openFirewall = true;
    };

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

  # XDG Desktop Portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Grouping related hardware configs
  hardware.bluetooth.enable = true;
}
