{
  flake.nixosModules.gonic =
    { config, ... }:
    let
      hl = config.homelab;
    in
    {
      # Set up gonic.
      services.gonic = {
        enable = true;
        settings = {
          music-path = "/public/Music";
          listen-addr = "127.0.0.1:4747";
          scan-watcher-enabled = true;
          multi-value-genre = "delim ;";
          multi-value-artist = "delim ;";
          multi-value-album-artist = "delim ;";
        };
      };

      # Setup Nginx because we have multiple services on this server.
      services.nginx.virtualHosts."gonic.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        enableAuthelia = true;

        locations."/" = {
          proxyPass = config.services.gonic.settings.listen-addr;
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
}
