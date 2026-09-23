{ inputs, ... }:
{
  flake.nixosModules.layernotes =
    { pkgs, lib, ... }:
    let
      layernotes = inputs.layernotes.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      environment.systemPackages = [ layernotes ];

      systemd.user.services.layernotes = {
        enable = true;
        description = "LayerNotes for Niri";

        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        requisite = [ "graphical-session.target" ];

        wantedBy = [ "niri.service" ];

        serviceConfig = {
          Type = "simple";
          Environment = "PATH=${lib.makeBinPath [ pkgs.xdg-utils ]}";
          ExecStartPre = "${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY";
          ExecStart = "${layernotes}/bin/layernotes";
          Restart = "always";
          RestartSec = 1;
        };
      };
    };
}
