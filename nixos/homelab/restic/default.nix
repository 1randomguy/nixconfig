{lib, pkgs, config, ...}:
with lib;
let
  cfg = config.homelab.services.restic;
  hl = config.homelab;
in
{
  options.homelab.services.restic = {
    enable = mkEnableOption {
      description = "Enable backups";
    };
    backupDirs = mkOption {
      type = types.listOf types.str;
      description = "The directories to backup";
      default = [];
    };
    s3.enable = mkOption {
      description = "Enable S3 backups for application state directories";
      default = false;
      type = types.bool;
    };
    local.enable = mkOption {
      description = "Enable local backups for application state directories";
      default = false;
      type = types.bool;
    };
    local.targetDir = mkOption {
      description = "Target path for local Restic backups";
      type = types.path;
    };
  };
  config =
    mkIf (cfg.enable && cfg.backupDirs != [ ]) {
      age.secrets.restic = {
        file = ../../../secrets/restic.age;
      };
      age.secrets.backblazeb2 = {
        file = ../../../secrets/backblazeb2.age;
      };
      systemd.tmpfiles.rules = lists.optionals cfg.local.enable [
        "d ${cfg.local.targetDir} 0770 ${hl.user} ${hl.group} - -"
      ];

      services.restic = {
        backups =
          attrsets.optionalAttrs cfg.local.enable {
            appdata-local = {
              timerConfig = {
                OnCalendar = "*-*-* 05:00:00";
                Persistent = true;
              };
              repository = cfg.local.targetDir; 
              initialize = true;
              passwordFile = config.age.secrets.restic.path;
              pruneOpts = [
                "--keep-daily 3"
                "--keep-weekly 3"
                "--keep-monthly 2"
              ];
              exclude = [
              ];
              paths = cfg.backupDirs;
            };
          }
          // attrsets.optionalAttrs cfg.s3.enable {
            appdata-s3 =
              {
                timerConfig = {
                  OnCalendar = "Sun *-*-* 05:00:00";
                  Persistent = true;
                };
                environmentFile = config.age.secrets.backblazeb2.path;
                repository = "s3:s3.eu-central-003.backblazeb2.com/3YLELy";
                initialize = true;
                passwordFile = config.age.secrets.restic.path;
                pruneOpts = [
                  "--keep-daily 2"
                  "--keep-weekly 3"
                  "--keep-monthly 9"
                ];
                exclude = [
                ];
                paths = cfg.backupDirs;
          };
      };
    };
}
