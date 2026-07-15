{ pkgs, config, ... }: 

{
# Modern Desktop Environment & Flatpak Dark Mode
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

# Legacy GTK Configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk2.extraConfig = ''
      gtk-theme-name = "Adwaita-dark"
      gtk-application-prefer-dark-theme = 1
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Qt Configuration
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  # Legacy flatpak and application theme fallback
  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
  };
}
