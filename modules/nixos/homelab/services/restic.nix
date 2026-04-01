{
  flake.nixosModules.restic =
    { lib, config, ... }:
    let
      cfg = config.homelab.services.restic;
      hl = config.homelab;
    in
    {
      options.homelab.services.restic = {
        backupDirs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "The directories to backup";
          default = [ ];
        };
        local.enable = lib.mkOption {
          description = "Enable local backups for application state directories";
          default = false;
          type = lib.types.bool;
        };
        local.targetDir = lib.mkOption {
          description = "Target path for local Restic backups";
          type = lib.types.path;
        };
        s3.enable = lib.mkOption {
          description = "Enable S3 backups for application state directories";
          default = false;
          type = lib.types.bool;
        };
      };
      config = lib.mkIf (cfg.backupDirs != [ ]) {
        age.secrets.restic = {
          file = ../../secrets/restic.age;
        };
        age.secrets.backblazeb2 = {
          file = ../../secrets/backblazeb2.age;
        };
        systemd.tmpfiles.rules = lib.lists.optionals cfg.local.enable [
          "d ${cfg.local.targetDir} 0770 ${hl.user} ${hl.group} - -"
        ];

        services.restic = {
          backups =
            lib.attrsets.optionalAttrs cfg.local.enable {
              appdata-local = {
                timerConfig = {
                  OnCalendar = "*-*-* 02:00:00";
                  Persistent = true;
                };
                repository = cfg.local.targetDir;
                initialize = true;
                passwordFile = config.age.secrets.restic.path;
                pruneOpts = [
                  "--keep-daily 7"
                  "--keep-weekly 5"
                  "--keep-monthly 12"
                ];
                exclude = [
                ];
                paths = cfg.backupDirs;
              };
            }
            // lib.attrsets.optionalAttrs cfg.s3.enable {
              appdata-s3 = {
                timerConfig = {
                  #OnCalendar = "Sun *-*-* 06:00:00";
                  OnCalendar = "*-*-* 02:00:00";
                  Persistent = true;
                };
                environmentFile = config.age.secrets.backblazeb2.path;
                repository = "s3:s3.eu-central-003.backblazeb2.com/3YLELy";
                initialize = true;
                passwordFile = config.age.secrets.restic.path;
                pruneOpts = [
                  "--keep-daily 1"
                  "--keep-weekly 3"
                  "--keep-monthly 5"
                ];
                exclude = [
                ];
                paths = cfg.backupDirs;
              };
            };
        };
      };
    };
}
