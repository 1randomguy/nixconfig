{
  flake.nixosModules.gonic =
    { config, ... }:
    let
      hl = config.homelab;
      address = "127.0.0.1:4747";
    in
    {
      # Set up gonic.
      services.gonic = {
        enable = true;
        settings = {
          music-path = "/public/Music";
          podcast-path = "/public/Podcasts";
          playlists-path = "/public/Music/Playlists";
          listen-addr = address;
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
          proxyPass = "http://${address}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
}
