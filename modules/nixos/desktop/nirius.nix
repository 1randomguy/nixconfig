{
  flake.nixosModules.nirius = {pkgs, ...}:
  {
    systemd.user.services.niriusd = {
      enable = true;
      description = "Nirius Daemon for Niri";

      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];

      wantedBy = [ "niri.service" ];

      serviceConfig = {
          Type = "simple";
          ExecStart = ''${pkgs.nirius}/bin/niriusd'';
          Restart = "always";
          RestartSec = 1;
      };
    };
  };
}
