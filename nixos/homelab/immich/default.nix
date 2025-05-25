{lib, config, ...}:
with lib;
let
  cfg = config.homelab.services.immich;
  hl = config.homelab;
in
{
  options.homelab.services.immich = {
    enable = mkEnableOption "Immich Picture Server";
    backupDirs = mkOption {
      type = listOf types.str;
      description = "The directories to backup";
    };
  };
  config = 
    let
      immich_dir = "/var/lib/immich";
    in
    mkIf cfg.enable {
      cfg.backupDirs = mkForce [
        "${immich_dir}/library"
        "${immich_dir}/backups"
      ];
      services.immich = {
        enable = true;
        port = 2283;
        # `null` will give access to all devices.
        # You may want to restrict this by using something like `[ "/dev/dri/renderD128" ]`
        accelerationDevices = null;
        #environment = {
        #  UPLOAD_LOCATION = "/data/immich_uploads";
        #};
      };
      users.users.immich = {
        isSystemUser = true;
        group = "immich";
        extraGroups = [ "video" "render" "media" ];
      };
  };
}
