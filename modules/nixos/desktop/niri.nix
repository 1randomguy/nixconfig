{
  flake.nixosModules.niri = {pkgs, ...}:
  {
    # Nirius
    systemd.user.services.niriusd = {
      enable = true;
      # Unit
      description = "Nirius Daemon for Niri";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      # Install
      wantedBy = [ "niri.service" ];
      # Service
      serviceConfig = {
          Type = "simple";
          ExecStart = ''${pkgs.nirius}/bin/niriusd'';
          Restart = "always";
          RestartSec = 1;
      };
    };
    # SwayOSD
    services.user.services.swayosd = {
      enable = true;
      # Unit
      description = "Volume/backlight OSD indicator";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      documentation = "man:swayosd(1)";
      startLimitBurst = 5;
      startLimitIntervalSec = 10;
      # Install
      wantedBy = [ "niri.service" ];
      # Service
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
          Restart = "always";
          RestartSec = 2;
      };
    };
  };
}
