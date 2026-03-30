{lib, config, ...}:
with lib;
let
  cfg = config.homelab.services.nfs;
  hl = config.homelab;
in
{
  options.homelab.services.nfs = {
    enable = mkEnableOption "NFS Fileshare";
    directory = mkOption {
      type = types.str;
      description = "The directory on the server to share";
      default = "/data";
    };
  };
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /export/data 0775 bene users - -"
    ];

    fileSystems."/export/data" = {
      device = cfg.directory;
      options = [ "bind" ];
    };

    services.nfs.server = {
      enable = true;
      # fixed rpc.statd port; for firewall
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      extraNfsdConfig = '''';
      exports = ''
        /export        *(ro,sync,fsid=0,no_subtree_check)
        /export/data   192.168.178.0/24(rw,insecure,sync,nohide,no_subtree_check)
      '';
    };

    homelab.services.restic.backupDirs = [ cfg.directory ];

    networking.firewall = {
      allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
      allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
    };
  };
}
