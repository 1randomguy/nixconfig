{lib, config, ...}:
with lib;
let
  cfg = config.homelab;
  hl = config.homelab;
  vhostOptions = {config,...}: {
    options = {
      enableAuthelia = lib.mkEnableOption "Enable authelia location";
    };
    config =
      lib.mkIf config.enableAuthelia {
        locations."/authelia".extraConfig = ''
          internal;
          set $upstream_authelia http://127.0.0.1:9091/api/verify;
          proxy_pass_request_body off;
          proxy_pass $upstream_authelia;    
          proxy_set_header Content-Length "";

          # Timeout if the real server is dead
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

          # [REQUIRED] Needed by Authelia to check authorizations of the resource.
          # Provide either X-Original-URL and X-Forwarded-Proto or
          # X-Forwarded-Proto, X-Forwarded-Host and X-Forwarded-Uri or both.
          # Those headers will be used by Authelia to deduce the target url of the     user.
          # Basic Proxy Config
          client_body_buffer_size 128k;
          proxy_set_header Host $host;
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $remote_addr; 
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-Ssl on;
          proxy_redirect  http://  $scheme://;
          proxy_http_version 1.1;
          proxy_set_header Connection "";
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 4 32k;

          # Advanced Proxy Config
          send_timeout 5m;
          proxy_read_timeout 240;
          proxy_send_timeout 240;
          proxy_connect_timeout 240;
        '';

        locations."/".extraConfig = lib.mkBefore ''
          default_type text/html;
          
          # Basic Authelia Config
          # Send a subsequent request to Authelia to verify if the user is authenticated
          # and has the right permissions to access the resource.
          auth_request /authelia;
          # Set the `target_url` variable based on the request. It will be used to build the portal
          # URL with the correct redirection parameter.
          auth_request_set $target_url $scheme://$http_host$request_uri;
          # Set the X-Forwarded-User and X-Forwarded-Groups with the headers
          # returned by Authelia for the backends which can consume them.
          # This is not safe, as the backend must make sure that they come from the
          # proxy. In the future, it's gonna be safe to just use OAuth.
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          auth_request_set $name $upstream_http_remote_name;
          auth_request_set $email $upstream_http_remote_email;
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;
          proxy_set_header Remote-Name $name;
          proxy_set_header Remote-Email $email;
          # If Authelia returns 401, then nginx redirects the user to the login portal.
          # If it returns 200, then the request pass through to the backend.
          # For other type of errors, nginx will handle them as usual.
          error_page 401 =302 https://auth.${hl.baseDomain}/?rd=$target_url;
        '';
      };
  };
in
{
  imports = [
    ./immich
    ./adguard
    ./smb
    ./nfs
    ./restic
    ./authelia
    ./ddclient
    ./nextcloud
    ./zola
    ./navidrome
  ];

  options.homelab = {
    enable = mkEnableOption "Homelab services and config";
    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
    };
    baseDomain = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = ''
        Base domain name to be used to access the homelab services via nginx reverse proxy
      '';
    };
  };
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule vhostOptions);
  };

  config = mkIf cfg.enable {
    users = {
      groups.${cfg.group} = {
        gid = 993;
      };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
        extraGroups = [ "video" "render" "media" ];
      };
    };

    networking.firewall.enable = true;
    networking.firewall.allowPing = true;

    virtualisation.docker.enable = true;

    age.secrets.porkbun = {
      file = ../../secrets/porkbun.age;
    };

    services.nginx = {
      enable = true;
      # recommended Settings
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      
      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      appendHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;

        # Enable CSP for your services.
        #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

        # Disable embedding as a frame
        add_header X-Frame-Options DENY;

        # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;

        # This might create errors
        #proxy_cookie_path / "/; secure; HttpOnly; SameSite=lax";
      '';
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "bblomberg123@gmail.com";
        dnsProvider = "porkbun";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.age.secrets.porkbun.path;
      };

      # certs."shimagumo.party" = {
      #   domain = "shimagumo.party";
      #   extraDomainNames = [ "*.shimagumo.party" ];
      # };
    };

    services.homepage-dashboard = {
      enable = true;
      environmentFile = builtins.toFile "homepage.env" "HOMEPAGE_ALLOWED_HOSTS=${cfg.baseDomain}";
      services = [
        {
          "Media" = [
            {
              "Immich" = {
                description = "Personal photos and videos";
                href = "https://immich.${cfg.baseDomain}";
                icon = "immich.svg";
              };
            }
            {
              "Navidrome" = {
                description = "Music streaming server";
                href = "https://music.${cfg.baseDomain}";
                icon = "navidrome.svg";
              };
            }
          ];
        }
        {
          "Network" = [
            {
              "AdGuard Home" = {
                description = "Network-wide ad blocker";
                href = "https://adguard.${cfg.baseDomain}";
                icon = "adguard-home.svg";
              };
            }
            {
              "Authelia" = {
                description = "Authentication portal for the homelab";
                href = "https://auth.${cfg.baseDomain}";
                icon = "authelia.svg";
              };
            }
          ];
        }
        {
          "Cloud" = [
            {
              "Nextcloud" = {
                description = "Personal cloud storage";
                href = "https://nextcloud.${cfg.baseDomain}";
                icon = "nextcloud.svg";
              };
            }
          ];
        }
        {
          "Services" = [
            {
              "Zola" = {
                description = "Static site generator";
                href = "https://zola.${cfg.baseDomain}";
                icon = "zola.svg";
              };
            }
          ];
        }
      ];
    };

    services.nginx.virtualHosts."${cfg.baseDomain}" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      enableAuthelia = true;

      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.homepage-dashboard.listenPort}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
