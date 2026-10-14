{
  flake.nixosModules.homelab = { lib, ... }: {
    options.homelab = {
      baseDomain = lib.mkOption {
        default = "";
        type = lib.types.str;
        description = ''
          Base domain name to be used to access the homelab services via nginx reverse proxy
        '';
      };
      notify.storage = {
        threshold = lib.mkOption {
          type = lib.types.ints.between 1 100;
          default = 90;
          description = "Usage percentage at which a storage warning is sent.";
        };
        pools = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "ZFS pools to watch for high usage.";
        };
        paths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Filesystem paths to watch for high usage (via df).";
        };
        mounts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Paths that must be mounted; alert if missing.";
        };
      };
      services.restic = {
        backupDirs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "The directories to backup";
          default = [ ];
        };
        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Paths to exclude from the backups";
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
        backblazeb2.enable = lib.mkOption {
          description = "Enable S3 backups to backblazeb2 for application state directories";
          default = false;
          type = lib.types.bool;
        };
      };
      services.immich = {
        mediaPath = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/var/lib/immich-media";
          description = ''
            Optional separate disk location for Immich's original photos
            (`upload`) and `library`. When set, these two directories are stored
            on `mediaPath` and bind-mounted into the Immich app directory, and
            they are backed up from `mediaPath`. Leave as `null` to keep
            everything under `/var/lib/immich` on the root filesystem.
          '';
        };
      };
      services.samba = {
        directory = lib.mkOption {
          type = lib.types.str;
          description = "The directory on the server to share";
          default = "/data";
        };
      };
      services.zola = {
        sourceDir = lib.mkOption {
          type = lib.types.path;
          description = "Path to your blog source directory";
          example = "/home/user/blog";
        };
        sourceOwner = lib.mkOption {
          type = lib.types.str;
          description = "User that owns your blog source directory";
          example = "user";
        };
      };
    };
  };
}
