{
  flake.nixosModules.paperless =
    { config, lib, ... }:
    let
      hl = config.homelab;
      consumeDir = "/var/lib/paperless/consume";
      inboxGroup = "paperless-inbox";
    in
    {
      age.secrets = {
        paperless_admin_password = {
          file = ../../../../secrets/paperless_admin_password.age;
        };
        paperless_oidc_env = {
          file = ../../../../secrets/paperless_oidc_env.age;
        };
      };

      users.groups.${inboxGroup} = {
        gid = 503;
      };

      users.users.paperless.extraGroups = [ inboxGroup ];
      users.users.bene.extraGroups = [ inboxGroup ];

      services.paperless = {
        enable = true;
        dataDir = "/var/lib/paperless";
        consumptionDir = consumeDir;
        passwordFile = config.age.secrets.paperless_admin_password.path;
        environmentFile = config.age.secrets.paperless_oidc_env.path;
        database.createLocally = true;
        configureNginx = true;
        domain = "paperless.${hl.baseDomain}";

        settings = {
          PAPERLESS_ADMIN_USER = "bene";
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
          PAPERLESS_CONSUMER_RECURSIVE = true;
          PAPERLESS_CONSUMER_IGNORE_PATTERNS = [
            ".stfolder"
            ".stfolder/*"
            ".stversions"
            ".stversions/*"
            ".stignore"
            ".syncthing.*.tmp"
            "~syncthing~*"
            ".DS_Store"
            "Thumbs.db"
          ];
        };
      };

      systemd.tmpfiles.settings."10-paperless" = {
        "${consumeDir}".d = lib.mkForce {
          user = "paperless";
          group = inboxGroup;
          mode = "2770";
        };
        "${consumeDir}/smb".d = {
          user = "paperless";
          group = inboxGroup;
          mode = "2770";
        };
      };

      services.samba.settings."paperless" = {
        path = "${consumeDir}/smb";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "bene";
        "force user" = "paperless";
        "force group" = inboxGroup;
        "create mask" = "0660";
        "directory mask" = "2770";
      };

      services.syncthing.settings.folders."Paperless" = {
        path = consumeDir;
        type = "sendreceive";
        devices = [
          "sanji"
          "work-laptop"
        ];
        ignorePatterns = [ "/smb/" ];
      };

      services.postgresqlBackup.databases = [ "paperless" ];
      homelab.services.restic.backupDirs = [ "/var/lib/paperless" ];

      services.nginx.virtualHosts."paperless.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        enableAuthelia = true;

        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubdomains" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header Referrer-Policy "strict-origin-when-cross-origin" always;
          add_header X-Robots-Tag "noindex, nofollow" always;
        '';

        locations."/".extraConfig = ''
          client_max_body_size 1G;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        '';
      };
    };
}
