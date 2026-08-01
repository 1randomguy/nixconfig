{
  flake.nixosModules.restic =
    { lib, config, ... }:
    let
      cfg = config.homelab.services.restic;
      hl = config.homelab;
      pgBackupLocation = "/var/backup/postgresql";
      pgBackupEnable = ((config.services.postgresqlBackup.databases or [ ]) != [ ]);
      backupDirs = cfg.backupDirs ++ lib.optionals pgBackupEnable [ pgBackupLocation ];
    in
    {
      config = lib.mkIf (backupDirs != [ ]) (lib.mkMerge [
        {
          age.secrets.restic.file = ../../../../secrets/restic.age;

          services.postgresqlBackup = lib.mkIf pgBackupEnable {
            enable = true;
            startAt = "*-*-* 02:00:00"; # Daily at 2 AM
            location = pgBackupLocation;
          };
        }
        (lib.mkIf cfg.local.enable {
          systemd.tmpfiles.rules = [
            "d ${cfg.local.targetDir} 0770 ${hl.user} ${hl.group} - -"
          ];

          services.restic.backups = {
            appdata-local = {
              timerConfig = {
                OnCalendar = "*-*-* 03:00:00"; # 1 hour after the postgresql backup
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
              paths = backupDirs;
            };
          };
        })
        (lib.mkIf cfg.backblazeb2.enable {
          age.secrets.backblazeb2.file = ../../../../secrets/backblazeb2.age;

          services.restic.backups = {
            appdata-s3 = {
              timerConfig = {
                #OnCalendar = "Sun *-*-* 06:00:00";
                OnCalendar = "*-*-* 03:00:00"; # 1 hour after the postgresql backup
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
              paths = backupDirs;
            };
          };
        })
      ]);
    };
}
