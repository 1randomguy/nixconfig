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
      #cfg.backupDirs = mkForce [
      #  "${immich_dir}/library"
      #  "${immich_dir}/backups"
      #];
      services.immich = {
        enable = true;
        port = 2283;
        user = hl.user;
        group = hl.group;
        # `null` will give access to all devices.
        # You may want to restrict this by using something like `[ "/dev/dri/renderD128" ]`
        accelerationDevices = null;
      };
      users.users.immich = {
        isSystemUser = true;
        group = "immich";
        extraGroups = [ "video" "render" "media" ];
      };

      services.nginx.virtualHosts."immich.shimagumo.party" = {
        enableACME = true;
        addSSL = true;
        #forceSSL = true;
        #sslCertificate = "/etc/ssl/selfsigned/selfsigned.crt";
        #sslCertificateKey = "/etc/ssl/selfsigned/selfsigned.key";
        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.immich.port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };
  };
}
