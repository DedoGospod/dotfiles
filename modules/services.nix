{ pkgs,... }:

{
  services = {
    openssh.enable = true;
    fstrim.enable = true;
    power-profiles-daemon.enable = true;
    gnome.gnome-keyring.enable = true;
    flatpak.enable = true;
    
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

  security.pam.services.login.enableGnomeKeyring = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # XDG Desktop Portals (D-Bus service for DE communication)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Grouping related hardware configs
  hardware.bluetooth.enable = true;
}
