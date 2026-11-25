{ inputs, ... }:
{
  flake.nixosModules.immich-public-proxy =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      hl = config.homelab;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      config = lib.mkIf (config.services.immich.enable) {
        services.immich-public-proxy = {
          enable = true;
          package = pkgs-unstable.immich-public-proxy;
          port = 2285;
          immichUrl = "http://[::1]:${toString config.services.immich.port}";
          settings = {
            ipp = {
              responseHeaders = {
                Cache-Control = "public; max-age=2592000";
                Access-Control-Allow-Origin = "*";
              };
              allowDownload = 1;
              showHomePage = true;
              gallery = {
                showDescription = true;
                showExpiryDate = true;
                expiryDateFormat = "DD.MM.YYYY";
              };
              showMetadata = {
                description = false;
              };
            };
          };
        };

        services.nginx.virtualHosts."share.immich.${hl.baseDomain}" = {
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;

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
    };
}
