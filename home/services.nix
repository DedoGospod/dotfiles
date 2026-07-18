{ pkgs, ... }:

{
  #services = {
    #easyeffects.enable = true;
  #};

  systemd.user.services.obs = {
    Unit = {
      Description = "OBS Studio";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/rm -rf %h/.config/obs-studio/.sentinel";
      ExecStart = "${pkgs.obs-studio}/bin/obs";
      Restart = "on-failure";
      RestartSec = "5s";
      StartLimitIntervalSec = 60;
      StartLimitBurst = 5;
      KillSignal = "SIGKILL";
    };
    #Install = {
    #    WantedBy = [ "graphical-session.target" ];
    #};

  };


}
