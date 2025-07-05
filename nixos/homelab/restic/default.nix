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
            #appdata-s3 =
            #  let
            #    backupFolder = "appdata-${config.networking.hostName}";
            #  in
            #  {
            #    timerConfig = {
            #      OnCalendar = "Sun *-*-* 05:00:00";
            #      Persistent = true;
            #    };
            #    environmentFile = cfg.s3.environmentFile;
            #    repository = "s3:${cfg.s3.url}/${backupFolder}";
            #    initialize = true;
            #    passwordFile = cfg.passwordFile;
            #    pruneOpts = [
            #      "--keep-last 3"
            #    ];
            #    exclude = [
            #    ];
            #    paths = [
            #      "/tmp/appdata-s3-${config.networking.hostName}.tar"
            #    ];
            #    backupPrepareCommand =
            #      let
            #        restic = "${pkgs.restic}/bin/restic -r '${config.services.restic.backups.appdata-s3.repository}' -p ${cfg.passwordFile}";
            #      in
            #      ''
            #        ${restic} stats || ${restic} init
            #        ${pkgs.restic}/bin/restic forget --prune --no-cache --keep-last 3
            #        ${pkgs.gnutar}/bin/tar -cf /tmp/appdata-s3-${config.networking.hostName}.tar ${backupDirs}
            #        ${restic} unlock
            #      '';
            #};
          };
      };
    };
}
