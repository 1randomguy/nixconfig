{
  flake.nixosModules.homelabOptions = { lib, ... }: {
    options.homelab = {
      user = lib.mkOption {
        default = "share";
        type = lib.types.str;
        description = ''
          User to run the homelab services as
        '';
      };
      group = lib.mkOption {
        default = "share";
        type = lib.types.str;
        description = ''
          Group to run the homelab services as
        '';
      };
      baseDomain = lib.mkOption {
        default = "";
        type = lib.types.str;
        description = ''
          Base domain name to be used to access the homelab services via nginx reverse proxy
        '';
      };
      services.restic = {
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
        backblazeb2.enable = lib.mkOption {
          description = "Enable S3 backups to backblazeb2 for application state directories";
          default = false;
          type = lib.types.bool;
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
