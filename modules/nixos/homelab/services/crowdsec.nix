{ inputs }:
{
  flake.nixosModules.crowdsec =
    { config, ... }:
    {
      disabledModules = [
        "services/security/crowdsec.nix"
        "services/security/crowdsec-firewall-bouncer.nix"
      ];
      imports = [
        "${inputs.crowdsec-pr}/nixos/modules/services/security/crowdsec.nix"
        "${inputs.crowdsec-pr}/nixos/modules/services/security/crowdsec-firewall-bouncer.nix"
      ];

      services.crowdsec = {
        enable = true;
        autoUpdateService = true;

        extraGroups = [
          "nginx"
          "systemd-journal"
        ];
        readOnlyPaths = [ "/var/log/nginx" ];

        hub.collections = [
          "crowdsecurity/nginx"
          "crowdsecurity/linux"
          "crowdsecurity/http-cve" # Adds protection against known web exploits
        ];

        hub.parsers = [
          "crowdsecurity/sshd-logs"
          "crowdsecurity/whitelists"
        ];

        hub.postoverflows = [
          "crowdsecurity/auditd-nix-wrappers-whitelist-process" # Ignore benign Nix wrapper execs
        ];

        # Tell CrowdSec where to find the Nginx logs
        settings.acquisitions = [
          {
            labels.type = "nginx";
            filenames = [
              "/var/log/nginx/access.log"
              "/var/log/nginx/error.log"
            ];
          }
          {
            labels.type = "syslog";
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          }
        ];

        settings.api.server = {
          enable = true;
          listen_uri = "127.0.0.1:8080";
        };

        settings.console = {
          enrollKeyFile = config.age.secrets.crowdsec_token.path;

          configuration = {
            share_manual_decisions = true;
            share_tainted = true;
            console_management = false; # Keep NixOS in control of your config
            share_context = true;
          };
        };

        crowdsec-firewall-bouncer.enable = true;
      };

      age.secrets.crowdsec_token = {
        file = ../../../../secrets/crowdsec_token.age;
      };
    };
}
