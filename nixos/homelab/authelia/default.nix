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
    services.authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = config.age.secrets.authelia_jwt_secret.path;
        storageEncryptionKeyFile = config.age.secrets.authelia_storage_encryption.path;
        sessionSecretFile = config.age.secrets.authelia_session_secret.path;
      };
      settings = {
        default_redirection_url = "https://${hl.baseDomain}";
    
        server = {
          #address = "tcp://127.0.0.1:9091";
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
    
        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = ["auth.${hl.baseDomain}"];
              policy = "bypass";
            }
            {
              domain = ["*.${hl.baseDomain}"];
              policy = "one_factor"; # other option: "two_factor"
            }
          ];
        };
    
        session = {
          name = "authelia_session";
          expiration = "12h";
          inactivity = "45m";
          remember_me = "1M";
          domain = "${hl.baseDomain}";
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
            filename = "/var/lib/authelia-main/notification.txt";
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
      };
    };
  };
}
