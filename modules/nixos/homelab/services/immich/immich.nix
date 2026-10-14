{inputs, ...}:
{
  flake.nixosModules.immich =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      hl = config.homelab;
      appDir = "/var/lib/immich";
      mediaPath = config.homelab.services.immich.mediaPath;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
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
        package = pkgs-unstable.immich;
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
          "docker"
        ];
      };

      services.postgresqlBackup = {
        databases = [ "immich" ];
      };

      # Back up the app directory, plus the external media path when in use.
      # The bind-mounted media views are excluded so media is only captured at
      # its real location (otherwise it can silently be missed if a bind mount
      # is not active during backup).
      homelab.services.restic.backupDirs = [ appDir ] ++ lib.optional (mediaPath != null) mediaPath;
      homelab.services.restic.exclude = lib.optionals (mediaPath != null) [
        "${appDir}/upload"
        "${appDir}/library"
      ];

      # Optionally keep original photos/library on a separate disk and bind-mount
      # them into the app directory. See `homelab.services.immich.mediaPath`.
      fileSystems = lib.mkIf (mediaPath != null) {
        "${appDir}/upload" = {
          device = "${mediaPath}/upload";
          fsType = "none";
          options = [ "bind" ];
          depends = [ mediaPath ];
        };
        "${appDir}/library" = {
          device = "${mediaPath}/library";
          fsType = "none";
          options = [ "bind" ];
          depends = [ mediaPath ];
        };
      };
      systemd.tmpfiles.rules = lib.optionals (mediaPath != null) [
        "d ${mediaPath}/upload 0750 immich immich -"
        "d ${mediaPath}/library 0750 immich immich -"
        "d ${appDir}/upload 0750 immich immich -"
        "d ${appDir}/library 0750 immich immich -"
      ];

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
