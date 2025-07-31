{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.workstation.nfs_mount;
in
{
  options.workstation.nfs_mount = {
    enable = mkEnableOption "NFS mount";
    directory = mkOption {
      type = types.str;
      description = "the diretory that the share will be mounted in";
      default = "/mnt/shared";
    };
    user = mkOption {
      type = types.str;
      description = "User that the share will belong to on the pc";
      default = "bene";
    };
    group = mkOption {
      type = types.str;
      description = "User that the share will belong to on the pc";
      default = "users";
    };
  };
  config = mkIf cfg.enable {
    #systemd.tmpfiles.rules = [
    #  "d ${cfg.directory} 0770 ${cfg.user} ${cfg.group} - -"
    #];
    #fileSystems."${cfg.directory}" = {
    #  device = "192.168.178.57:/export/data";
    #  fsType = "nfs";
    #  #options = [ "x-systemd.automount" "noauto" ];
    #  #options = [ "vers=4" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "user" ];
    #};
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true; # needed for NFS

    systemd.mounts = [{
      type = "nfs";
      mountConfig = {
        Options = "noatime,rsize=8192,wsize=8192,hard,intr,noauto"; #maybe soft with timeo and retrans instead?
        TimeoutSec = "10";
      };
      what = "192.168.178.57:/export/data";
      where = cfg.directory;
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    }];

    systemd.automounts = [{
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = cfg.directory;
    }];
  };
}
