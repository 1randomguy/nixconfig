{ self, ... }:
{
  flake.nixosModules.ashell =
    { pkgs, lib, ... }:
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
          Environment = "PATH=${
            lib.makeBinPath [
              pkgs.bash
              pkgs.systemd
              pkgs.coreutils
              pkgs.util-linux
              pkgs.playerctl
              pkgs.pwvucontrol
              pkgs.networkmanagerapplet
              pkgs.blueman
            ]
          }";
          ExecStart = "${selfpkgs.ashell}/bin/ashell";
          Restart = "always";
          RestartSec = 1;
        };
      };
    };
}
