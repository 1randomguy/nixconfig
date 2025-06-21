{lib, config, ...}:
with lib;
let
  cfg = config.homelab;
in
{
  imports = [
    ./immich
    ./adguard
    #./smb
    ./restic
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
        proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
      '';
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "bblomberg123@gmail.com";
        dnsProvider = "porkbun";
        environmentFile = config.age.secrets.porkbun.path;
      };

      # certs."shimagumo.party" = {
      #   domain = "shimagumo.party";
      #   extraDomainNames = [ "*.shimagumo.party" ];
      # };
    };
    #services.nginx.virtualHosts.localhost = {
    #  locations."/" = {
    #    return = "200 '<html><body>It works</body></html>'";
    #    extraConfig = ''
    #      default_type text/html;
    #    '';
    #  };
    #};
  };
}
