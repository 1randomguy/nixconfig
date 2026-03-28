{self, ...}:
{
  flake.nixosModules.ashell = {pkgs, ...}:
  let
    selfpkgs = self.packages."${pkgs.system}";
  in
  {
    systemd.user.services.ashell = {
      enable = true;
      description = "Ashell for Niri";

      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];

      wantedBy = [ "niri.service" ];

      serviceConfig = {
          Type = "simple";
          ExecStart = ''${selfpkgs.ashell}/bin/ashell'';
          Restart = "always";
          RestartSec = 1;
      };
    };
  };
}
