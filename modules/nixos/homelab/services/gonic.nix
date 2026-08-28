{
  flake.nixosModules.gonic =
    { config, ... }:
    let
      hl = config.homelab;
      port = "4747";
    in
    {
      # Set up gonic.
      services.gonic = {
        enable = true;
        settings = {
          music-path = "/public/Music";
          podcast-path = "/public/Podcasts";
          playlists-path = "/public/Music/Playlists";
          listen-addr = "0.0.0.0:${port}";
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
          proxyPass = "http://127.0.0.1:${port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };

        # Allow Subsonic API requests through without Authelia redirects
        locations."/rest" = {
          proxyPass = "http://127.0.0.1:${port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            auth_request off;
          '';
        };
      };
    };
}
