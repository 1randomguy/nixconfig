{
  flake.nixosModules.navidrome =
    { config, ... }:
    let
      hl = config.homelab;
    in
    {
      # Set up the user in case you need consistent UIDs and GIDs.
      users.groups.navidrome = { };
      users.users.navidrome = {
        isSystemUser = true;
        group = "navidrome";
        extraGroups = [ "media" ];
      };

      # Set up Navidrome.
      services.navidrome = {
        enable = true;
        settings = {
          MusicFolder = "/export/data/Music";
          DataFolder = "/var/lib/navidrome";
          Address = "127.0.0.1";
          Port = 4533;
          LogLevel = "info";
        };
      };

      # Setup Nginx because we have multiple services on this server.
      services.nginx.virtualHosts."music.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        #enableAuthelia = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
}
