{
  flake.nixosModules.sub-wave =
    { config, ... }:
    let
      hl = config.homelab;
      state_dir = "/var/lib/subwave/state";
    in
    {
      age.secrets."subwave-env" = {
        file = ../../../../secrets/subwave-env.age;
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
              "127.0.0.1:7700:80" # Map host 7700 to internal Caddy edge on port 80
            ];
            volumes = [
              # Persistent state directory for SQLite DB, logs, and caches
              "${state_dir}:/var/sub-wave"
            ];
            environment = {
              ADMIN_USER = "admin";
              SITE_URL = "https://radio.${hl.baseDomain}";
              TZ = config.time.timeZone;
            };
            # Pulls the decrypted ADMIN_PASS environment variable from agenix
            environmentFiles = [
              config.age.secrets."subwave-env".path
            ];
            extraOptions = [
              "--add-host=host.docker.internal:host-gateway"
            ];
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
        enableAuthelia = false;

        locations."/" = {
          proxyPass = "http://127.0.0.1:7700";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_buffering off;
            proxy_read_timeout 1h;
          '';
        };
      };
    };
}
