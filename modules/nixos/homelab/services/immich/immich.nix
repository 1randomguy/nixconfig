{
  flake.nixosModules.immich =
    { config, ... }:
    let
      hl = config.homelab;
    in
    {
      services.immich = {
        enable = true;
        port = 2283;
        # `null` will give access to all devices.
        # You may want to restrict this by using something like `[ "/dev/dri/renderD128" ]`
        accelerationDevices = null;
        environment = {
          #DB_SKIP_MIGRATIONS = "true"; # NOTE: tmp for migration
        };
      };

      users.groups.immich = {
        gid = 502;
      };
      users.users.immich = {
        isSystemUser = true;
        uid = 502;
        extraGroups = [
          "video"
          "render"
          "media"
          "podman"
          "docker"
        ];
      };

      homelab.services.restic.backupDirs = [ "/var/lib/immich" ];

      services.nginx.virtualHosts."immich.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        enableAuthelia = true;
        extraConfig = ''
          # Set headers
          client_max_body_size 50000M;

          # Something here broke the app
          #proxy_redirect off;
        '';

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
