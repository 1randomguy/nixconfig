{lib, config, ...}:
with lib;
let
  cfg = config.homelab.services.immich;
  hl = config.homelab;
in
{
  options.homelab.services.immich = {
    enable = mkEnableOption "Immich Picture Server";
  };
  config = 
    mkIf cfg.enable {
      services.immich = {
        enable = true;
        port = 2283;
        group = hl.group;
        # `null` will give access to all devices.
        # You may want to restrict this by using something like `[ "/dev/dri/renderD128" ]`
        accelerationDevices = null;
        environment = { 
          #DB_SKIP_MIGRATIONS = "true"; # NOTE: tmp for migration
        };
      };

      users.users.immich = {
        isSystemUser = true;
        extraGroups = [ "video" "render" "media" ];
      };

      homelab.services.restic.backupDirs = [ "/var/lib/immich" ];

      services.nginx.virtualHosts."immich.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        enableAuthelia = true;
        extraConfig = ''
          # Set headers
          proxy_set_header Host              $host;
          proxy_set_header X-Real-IP         $remote_addr;
          proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;

          # Something here broke the app
          #proxy_set_header X-Forwarded-Proto $scheme;
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

      services.immich-public-proxy = {
        enable = true;
        port = 2285;
        immichUrl = "http://[::1]:${toString config.services.immich.port}";
        settings = {
          ipp = {
            responseHeaders = {
              Cache-Control = "public; max-age=2592000";
              Access-Control-Allow-Origin =  "*";
            };
            singleImageGallery = false;
            singleItemAutoOpen = true;
            downloadOriginalPhoto = true;
            allowDownloadAll = 1;
            showHomePage = true;
            showGalleryTitle = true;
            showMetadata = {
              description = false;
            };
            customInvalidResponse = false;
          };
          lightGallery = {
            controls = true;
            download = true;
            mobileSettings = {
              controls = false;
              showCloseIcon = true;
              download = true;
            };
          };
        };
      };

      services.nginx.virtualHosts."share.immich.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          # Set headers
          proxy_set_header Host              $host;
          proxy_set_header X-Real-IP         $remote_addr;
          proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        '';

        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.immich-public-proxy.port}";
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
