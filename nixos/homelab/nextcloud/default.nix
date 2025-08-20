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
    # `/var/backups/postgresql/nextcloud.gz`.
    services.postgresqlBackup = {
      enable = true;
      databases = [ "nextcloud" ];
      startAt = "*-*-* 02:00:00";  # Daily at 2 AM
      location = "/var/backup/postgresql";
    };

    homelab.services.restic.backupDirs = [ "/var/lib/nextcloud" "/var/backups/postgresql" ];

    # Set up secrets. This is a sops-nix file checked in at the same folder as
    # this file. 
    age.secrets = {
      nextcloud_admin_password = {
        file = ../../../secrets/nextcloud_admin_password.age;
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
      #secretFile = config.age.secrets.nextcloud_secrets.path;

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
        # TODO: Authelia OIDC
        allow_user_to_change_display_name = false;
        lost_password_link = "disabled";
        oidc_login_provider_url = "https://auth.${hl.baseDomain}";
        oidc_login_client_id = "nextcloud";
        oidc_login_client_secret = "insecure_secret";
        oidc_login_auto_redirect = false;
        oidc_login_end_session_redirect = false;
        oidc_login_button_text = "Log in with Authelia";
        oidc_login_hide_password_form = false;
        oidc_login_use_id_token = false;
        oidc_login_attributes = {
            id = "preferred_username";
            name = "name";
            mail = "email";
            groups = "groups";
            is_admin = "is_nextcloud_admin";
        };
        oidc_login_default_group = "oidc";
        oidc_login_use_external_storage = false;
        oidc_login_scope = "openid profile email groups nextcloud_userinfo";
        oidc_login_proxy_ldap = false;
        oidc_login_disable_registration = true;
        oidc_login_redir_fallback = false;
        oidc_login_tls_verify = true;
        oidc_create_groups = false;
        oidc_login_webdav_enabled = false;
        oidc_login_password_authentication = false;
        oidc_login_public_key_caching_time = 86400;
        oidc_login_min_time_between_jwks_requests = 10;
        oidc_login_well_known_caching_time = 86400;
        oidc_login_update_avatar = false;
        oidc_login_code_challenge_method = "S256";
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
        inherit calendar contacts mail notes tasks;
        oidc = pkgs.fetchNextcloudApp rec {
          url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.2.2/oidc_login.tar.gz";
          sha256 = "18kxpbnpqizzqj78wl5qxi1v3s44vb3dzb7zrsp1mprww6w2mdj4";
          license = "no";
        };
      };
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
