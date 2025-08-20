{ pkgs, lib, config, ... }:
let
  cfg = config.homelab.services.nextcloud;
  hl = config.homelab;
in
{
  options.homelab.services.nextcloud = {
    enable = lib.mkEnableOption "Enable the Nextcloud server instance";
  };

  config = lib.mkIf cfg.enable {
    # Set up the user in case you need consistent UIDs and GIDs. And also to make
    # sure we can write out the secrets file with the proper permissions.
    users.groups.nextcloud = { };
    users.users.nextcloud = {
      isSystemUser = true;
      group = "nextcloud";
    };

    # Set up backing up the database automatically. The path will be in
    # `/var/backups/mysql/nextcloud.gz`.
    services.mysqlBackup.databases = [ "nextcloud" ];

    homelab.services.restic.backupDirs = [ "/var/lib/nextcloud/data" "/var/backups/mysql" ];

    # Set up secrets. This is a sops-nix file checked in at the same folder as
    # this file. #TODO: change to agenix
    age.secrets = {
      nextcloud_admin_password = {
        file = ../../secrets/x;
        owner = "nextcloud";
        group = "nextcloud";
      };
      nextcloud_db_password = {
        file = ../../secrets/x;
        owner = "nextcloud";
        group = "nextcloud";
      };
      nextcloud_secrets = {
        file = ../../secrets/x;
        owner = "nextcloud";
        group = "nextcloud";
      };
    };

    # Set up Nextcloud.
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      https = true;
      hostName = "cloud.${hl.baseDomain}";
      secretFile = config.age.secrets.nextcloud_secrets.path;

      phpOptions."opcache.interned_strings_buffer" = "13";

      config = {
        dbtype = "mysql";
        dbname = "nextcloud";
        dbhost = "localhost";
        dbpassFile = config.age.secrets.nextcloud_db_password;

        adminuser = "admin";
        adminpassFile = config.age.secrets.nextcloud_admin_password;
      };

      settings = {
        maintenance_window_start = 2; # 02:00
        default_phone_region = "de";
        filelocking.enabled = true;

        redis = {
          host = config.services.redis.servers.nextcloud.bind;
          port = config.services.redis.servers.nextcloud.port;
          dbindex = 0;
          timeout = 1.5;
        };
      };

      caching = {
        redis = true;
        memcached = true;
      };
    };

    # Set up Redis because the admin page was complaining about it.
    # https://discourse.nixos.org/t/nextlcoud-with-redis-distributed-cashing-and-file-locking/25321/3
    services.redis.servers.nextcloud = {
      enable = true;
      bind = "::1";
      port = 6379;
    };

    # Setup Nginx because we have multiple services on this server.
    services.nginx.virtualHosts."cloud.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
