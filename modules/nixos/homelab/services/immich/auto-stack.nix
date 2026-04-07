{
  flake.nixosModules.immich-auto-stacker =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      config = lib.mkIf (config.services.immich.enable) {
        virtualisation.docker.enable = true;

        systemd.timers."immich-auto-stacker" = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "10m";
            OnUnitActiveSec = "1h";
            Unit = "immich-auto-stacker.service";
            Persistent = true;
          };
        };

        systemd.services."immich-auto-stacker" = {
          description = "Immich Stacker";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];

          serviceConfig = {
            Type = "oneshot";
            User = "immich";
            ExecStart = "${pkgs.docker}/bin/docker run --rm --network=host --env-file=${config.age.secrets.auto-stacker-env.path} mattdavis90/immich-stacker";
          };
          path = [
            pkgs.watchexec
            pkgs.zola
          ];
        };

        age.secrets."auto-stacker-env" = {
          file = ../../../../../secrets/auto_stacker_env.age;
          owner = "immich";
        };
      };
    };
}
