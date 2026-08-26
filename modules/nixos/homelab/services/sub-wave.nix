{
  flake.nixosModules.sub-wave =
    { config, ... }:
    let
      hl = config.homelab;
      state_dir = "/var/lib/subwave/state";
      port = "7700";
    in
    {
      age.secrets."subwave-env" = {
        file = ../secrets/subwave-env.age;
        mode = "0400";
        # If running rootless Podman/Docker, set owner to your user UID
        owner = "root";
      };

      virtualisation.oci-containers = {
        backend = "docker"; # or "docker"
        containers = {
          subwave = {
            image = "ghcr.io/perminder-klair/subwave-aio:latest";
            autoStart = true;
            ports = [
              "7700:7700" # Web Player & Admin Interface
            ];
            volumes = [
              # Persistent state directory for SQLite DB, logs, and caches
              "${state_dir}:/app/state"
            ];
            environment = {
              PORT = port;
              ADMIN_USER = "admin";
              SITE_URL = "http://127.0.0.1:7700";
            };
            # Pulls the decrypted ADMIN_PASS environment variable from agenix
            environmentFiles = [
              config.age.secrets."subwave-env".path
            ];
            # Host networking enables direct communication with your existing Gonic server on localhost
            extraOptions = [ "--network=host" ];
          };
        };
      };

      # Create state directory with proper permissions
      systemd.tmpfiles.rules = [
        "d ${state_dir} 0755 root root -"
      ];

      services.nginx.virtualHosts."radio.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        enableAuthelia = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
}
