{
  flake.nixosModules.ddns-updater =
    { config, ... }:
    {
      services.crowdsec = {
        enable = true;

        hub.collections = [
          "crowdsecurity/nginx"
          "crowdsecurity/linux"
          "crowdsecurity/http-cve" # Adds protection against known web exploits
        ];

        # Tell CrowdSec where to find the Nginx logs
        localConfig.acquisitions = [
          {
            source = "file";
            labels.type = "nginx";
            filenames = [
              "/var/log/nginx/access.log"
              "/var/log/nginx/error.log"
            ];
          }
        ];

        settings.api.server = {
          enable = true;
          listen_uri = "127.0.0.1:8080";
        };

        settings.console = {
          tokenFile = config.age.secrets.crowdsec_token.path;

          configuration = {
            share_manual_decisions = true;
            share_tainted = true;
            console_management = false; # Keep NixOS in control of your config
            share_context = true;
          };
        };
      };

      services.crowdsec-firewall-bouncer = {
        enable = true;
        # It will automatically hook into your default NixOS firewall (iptables or nftables)
      };

      age.secrets.crowdsec_token = {
        file = ../../../../secrets/crowdsec_token.age;
      };
    };
}
