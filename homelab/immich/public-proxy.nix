{ lib, config, ... }:
let
  cfg = config.homelab.services.immich.public-proxy;
  im = config.homelab.services.immich;
  hl = config.homelab;
in
{
  options.homelab.services.immich.public-proxy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Public proxy for sharing singular photos or albums under a separate domain that can be made publically available safely";
    };
  };

  config = lib.mkIf (cfg.enable && im.enable) {
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
