{lib, config, ...}:
let
  cfg = config.homelab.immich.auto-stack;
  hl = config.homelab;
in
{
  options.homelab.services.immich.auto-stack = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Runs auto-stacker on a timer";
    };

  };

  config = lib.mkIf (cfg.enable && hl.services.immich.enable) {
    systemd.timers."immich-auto-stacker" = {
      wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30m";
          OnUnitActiveSec = "1h";
          Unit = "immich-auto-stacker.service";
        };
    };

    systemd.services."immich-auto-stacker" = {
      script = ''
        docker run -ti --rm --env-file=${config.age.secrets.auto-stacker-env.path} mattdavis90/immich-stacker
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "immich";
      };
    };

    age.secrets."auto-stacker-env".file = ../../../secrets/auto_stacker_env.age; 
  };
}
