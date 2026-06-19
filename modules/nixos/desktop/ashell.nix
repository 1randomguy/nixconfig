{ self, ... }:
{
  flake.nixosModules.ashell =
    { pkgs, lib, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = [ selfpkgs.ashell ];

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
          ExecStartPre = "${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY";
          ExecStart = "${selfpkgs.ashell}/bin/ashell";
          Restart = "always";
          RestartSec = 1;
        };
      };
    };
}
