{
  flake.nixosModules.nextcloud =
    { pkgs, config, ... }:
    let
      hl = config.homelab;
    in
    {
      # Set up the user in case you need consistent UIDs and GIDs. And also to make
      # sure we can write out the secrets file with the proper permissions.
      users.groups.nextcloud = { };
      users.users.nextcloud = {
        isSystemUser = true;
        group = "nextcloud";
        extraGroups = [ "media" ];
      };

      # Set up backing up the database automatically. The path will be in
      # `/var/backups/postgresql/nextcloud.gz`.
      services.postgresqlBackup = {
        enable = true;
        databases = [ "nextcloud" ];
        startAt = "*-*-* 02:00:00"; # Daily at 2 AM
        location = "/var/backup/postgresql";
      };

      homelab.services.restic.backupDirs = [
        "/var/lib/nextcloud"
        "/var/backup/postgresql"
      ];

      # Set up secrets. This is a sops-nix file checked in at the same folder as
      # this file.
      age.secrets = {
        nextcloud_admin_password = {
          file = ../../secrets/nextcloud_admin_password.age;
          owner = "nextcloud";
          group = "nextcloud";
        };
      };

      # Set up Nextcloud.
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud33;
        https = true;

        hostName = "nextcloud.${hl.baseDomain}";

        phpOptions."opcache.interned_strings_buffer" = "13";

        # Let NixOS install and configure Redis caching automatically.
        configureRedis = true;

        # Increase the maximum file upload size to avoid problems uploading videos.
        maxUploadSize = "16G";

        # Let NixOS install and configure the database automatically.
        database.createLocally = true;

        config = {
          dbtype = "pgsql";

          adminuser = "admin";
          adminpassFile = config.age.secrets.nextcloud_admin_password.path;
        };

        settings = {
          maintenance_window_start = 2; # 02:00
          default_phone_region = "de";
          filelocking.enabled = true;
          session_lifetime = "2592000";
          # Authelia OIDC
          allow_user_to_change_display_name = false;
          lost_password_link = "disabled";
          ## for config of user_oidc look at nextcloud_secrets.age
        };

        caching = {
          redis = true;
          memcached = true;
        };

        autoUpdateApps.enable = true;
        extraAppsEnable = true;
        extraApps = with config.services.nextcloud.package.packages.apps; {
          # List of apps we want to install and are already packaged in
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
          inherit
            calendar
            contacts
            mail
            notes
            tasks
            ;
          # custom apps ref: https://github.com/helsinki-systems/nc4nix/blob/main/31.json
          #oidc_login = pkgs.fetchNextcloudApp {
          #  url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.2.2/oidc_login.tar.gz";
          #  sha256 = "sha256-RLYquOE83xquzv+s38bahOixQ+y4UI6OxP9HfO26faI=";
          #  license = "agpl3Plus";
          #};
          user_oidc = pkgs.fetchNextcloudApp {
            url = "https://github.com/nextcloud-releases/user_oidc/releases/download/v8.6.1/user_oidc-v8.6.1.tar.gz";
            sha256 = "sha256-Xl35Ss/P6PvK6pvm7i/J+0EHJaLPbOCffR8ZT5c3XA4=";
            description = "Allows flexible configuration of an OIDC server as Nextcloud login user backend.";
            license = "agpl3Plus";
          };
        };
      };

      # Setup Nginx because we have multiple services on this server.
      services.nginx.virtualHosts."cloud.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        locations."/".return = "301 https://nextcloud.${hl.baseDomain}$request_uri";
      };

      services.nginx.virtualHosts."nextcloud.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          add_header X-Robots-Tag "noindex, nofollow" always;
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Permitted-Cross-Domain-Policies "none" always;

          # Re-apply your global security headers here so they aren't lost
          add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload" always;
          add_header Referrer-Policy "strict-origin-when-cross-origin" always;
          add_header X-Content-Type-Options "nosniff" always;
        '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
