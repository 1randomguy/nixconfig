{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.homelab.services.authelia;
  hl = config.homelab;
in
{
  options.homelab.services.authelia = {
    enable = mkEnableOption "Authelia service";
  };

  config = mkIf cfg.enable {
    age.secrets.authelia_jwt_secret = {
      file = ../../../secrets/authelia_jwt_secret.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    age.secrets.authelia_storage_encryption = {
      file = ../../../secrets/authelia_storage_encryption.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    age.secrets.authelia_session_secret = {
      file = ../../../secrets/authelia_session_secret.age;
      owner = "authelia-main";
      group = "authelia-main";
    };
    homelab.services.restic.backupDirs = [ "/var/lib/authelia-main" ];

    services.authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = config.age.secrets.authelia_jwt_secret.path;
        storageEncryptionKeyFile = config.age.secrets.authelia_storage_encryption.path;
        sessionSecretFile = config.age.secrets.authelia_session_secret.path;
      };
      settings = {
    
        server = {
          address = "tcp://127.0.0.1:9091";
        };
    
        log = {
          level = "debug";
          format = "text";
        };
    
        authentication_backend = {
          file = {
            path = "/var/lib/authelia-main/users_database.yml";
          };
        };

        totp = {
          disable = false;
          issuer = "Shimagumo";
        };
    
        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = ["auth.${hl.baseDomain}"];
              policy = "bypass";
            }
            {
              domain = ["adguard.${hl.baseDomain}"];
              policy = "one_factor"; # other option: "two_factor"
              subject = ["group:admins"];
            }
            {
              domain = ["immich.${hl.baseDomain}"];
              policy = "one_factor"; # other option: "two_factor"
            }
          ];
        };
    
        session = {
          name = "authelia_session";
          expiration = "12h";
          inactivity = "45m";
          remember_me = "1M";
          cookies = [
            {
              domain = "${hl.baseDomain}";
              authelia_url = "https://auth.${hl.baseDomain}";
              default_redirection_url = "https://${hl.baseDomain}";
            }
          ];
          redis.host = "/run/redis-authelia-main/redis.sock";
        };
    
        regulation = {
          max_retries = 3;
          find_time = "5m";
          ban_time = "15m";
        };
    
        storage = {
          local = {
            path = "/var/lib/authelia-main/db.sqlite3";
          };
        };
    
        notifier = {
          disable_startup_check = false;
          filesystem = {
            filename = "/public/notification.txt";
          };
        };
      };
    };
    services.redis.servers.authelia-main = {
      enable = true;
      user = "authelia-main";   
      port = 0;
      unixSocket = "/run/redis-authelia-main/redis.sock";
      unixSocketPerm = 600;
    };
    services.nginx.virtualHosts."auth.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:9091";
        proxyWebsockets = true;
        extraConfig = ''
          # Essential proxy headers for Authelia
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-Ssl on;
          
          # Handle redirects properly
          proxy_redirect http:// $scheme://;
          proxy_redirect http://127.0.0.1:9091/ $scheme://$http_host/;
          
          # WebSocket support
          # proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          
          # Buffer settings
          proxy_buffering off;
          proxy_buffer_size 4k;
          proxy_buffers 64 4k;
          proxy_busy_buffers_size 8k;
          
          # Timeout settings
          proxy_read_timeout 86400s;
          proxy_send_timeout 86400s;
          
          # Don't cache auth responses
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          
          # Security headers passthrough
          proxy_pass_header Server;
        '';
      };
    };
  };
}
