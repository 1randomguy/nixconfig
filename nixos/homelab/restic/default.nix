{lib, pkgs, config, ...}:
with lib;
let
  cfg = config.homelab.services.backup;
  hl = config.homelab;
in
{
  options.homelab.services.backup = {
    enable = mkEnableOption {
      description = "Enable backups";
    };
    state.enable = mkOption {
      description = "Enable backups for application state folders";
      type = types.bool;
      default = false;
    };
    passwordFile = mkOption {
      description = "File with password to the Restic repository";
      type = types.path;
    };
    s3.enable = mkOption {
      description = "Enable S3 backups for application state directories";
      default = false;
      type = types.bool;
    };
    s3.url = mkOption {
      description = "URL of the S3-compatible endpoint to send the backups to";
      default = "";
      type = types.str;
    };
    s3.environmentFile = mkOption {
      description = "File with S3 credentials";
      type = types.path;
      example = literalExpression ''
        pkgs.writeText "restic-s3-environment" '''
          AWS_DEFAULT_REGION=us-east-3
          AWS_ACCESS_KEY_ID=3u7heDiN4GGfuE8ocqLwS1d5zhy6I
          AWS_SECRET_ACCESS_KEY=3s3W4yCG5UDOzs1TMCohE6sc71U
        '''
      '';
    };
    local.enable = mkOption {
      description = "Enable local backups for application state directories";
      default = false;
      type = types.bool;
    };
    local.targetDir = mkOption {
      description = "Target path for local Restic backups";
      default = "${hl.mounts.merged}/Backups/Restic";
      type = types.path;
    };
  };
  config =
    let
      enabledServices = (
        attrsets.filterAttrs (
          name: value: value ? backupDirs && value ? enable && value.enable
        ) hl.services
      );
      backupDirs = strings.concatMapStrings (x: x + " ") (
        lists.flatten (
          lists.forEach (attrsets.mapAttrsToList (name: value: name) enabledServices) (
            x:
            attrsets.attrByPath [
              x
              "backupDirs"
            ] false enabledServices
          )
        )
      );
    in
    mkIf (cfg.enable && enabledServices != { }) {
      systemd.tmpfiles.rules = lists.optionals cfg.local.enable [
        "d ${cfg.local.targetDir} 0770 ${hl.user} ${hl.group} - -"
      ];
      users.users.restic.createHome = mkForce false;
      systemd.services.restic-rest-server.serviceConfig = attrsets.optionalAttrs cfg.local.enable {
        User = mkForce hl.user;
        Group = mkForce hl.group;
      };
      services.restic = {
        server = attrsets.optionalAttrs cfg.local.enable {
          enable = true;
          dataDir = cfg.local.targetDir;
          extraFlags = [
            "--no-auth"
          ];
        };
        backups =
          attrsets.optionalAttrs cfg.local.enable {
            appdata-local = {
              timerConfig = {
                OnCalendar = "Mon..Sat *-*-* 05:00:00";
                Persistent = true;
              };
              repository = "rest:http://localhost:8000/appdata-local-${config.networking.hostName}"; # TODO: Why? Also: focus on local first!
              initialize = true;
              passwordFile = cfg.passwordFile;
              pruneOpts = [
                "--keep-last 5"
              ];
              exclude = [
              ];
              paths = [
                "/tmp/appdata-local-${config.networking.hostName}.tar"
              ];
              backupPrepareCommand =
                let
                  restic = "${pkgs.restic}/bin/restic -r '${config.services.restic.backups.appdata-local.repository}' -p ${cfg.passwordFile}";
                in
                ''
                  ${restic} stats || ${restic} init
                  ${pkgs.restic}/bin/restic forget --prune --no-cache --keep-last 5
                  ${pkgs.gnutar}/bin/tar -cf /tmp/appdata-local-${config.networking.hostName}.tar ${backupDirs}
                  ${restic} unlock
                '';
            };
          }
          // attrsets.optionalAttrs cfg.s3.enable {
            appdata-s3 =
              let
                backupFolder = "appdata-${config.networking.hostName}";
              in
              {
                timerConfig = {
                  OnCalendar = "Sun *-*-* 05:00:00";
                  Persistent = true;
                };
                environmentFile = cfg.s3.environmentFile;
                repository = "s3:${cfg.s3.url}/${backupFolder}";
                initialize = true;
                passwordFile = cfg.passwordFile;
                pruneOpts = [
                  "--keep-last 3"
                ];
                exclude = [
                ];
                paths = [
                  "/tmp/appdata-s3-${config.networking.hostName}.tar"
                ];
                backupPrepareCommand =
                  let
                    restic = "${pkgs.restic}/bin/restic -r '${config.services.restic.backups.appdata-s3.repository}' -p ${cfg.passwordFile}";
                  in
                  ''
                    ${restic} stats || ${restic} init
                    ${pkgs.restic}/bin/restic forget --prune --no-cache --keep-last 3
                    ${pkgs.gnutar}/bin/tar -cf /tmp/appdata-s3-${config.networking.hostName}.tar ${backupDirs}
                    ${restic} unlock
                  '';
              };
          };
      };
    };
}
