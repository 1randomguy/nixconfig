{ self, inputs, ... }:
{
  flake.nixosModules.crowdsec =
    { pkgs, config, ... }:
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

        package = inputs.crowdsec-pr.legacyPackages.${pkgs.stdenv.hostPlatform.system}.crowdsec;
        # package = pkgs.crowdsec.overrideAttrs (old: {
        #   postInstall = (old.postInstall or "") + ''
        #     mkdir -p $out/libexec/crowdsec/plugins/
        #     touch $out/libexec/crowdsec/plugins/notification-dummy
        #     chmod +x $out/libexec/crowdsec/plugins/notification-dummy
        #     touch $out/libexec/crowdsec/plugins/notification-email
        #     chmod +x $out/libexec/crowdsec/plugins/notification-email
        #   '';
        # });

        extraGroups = [
          "nginx"
          "systemd-journal"
        ];

        readOnlyPaths = [ "/var/log/nginx" ];

        hub = {
          collections = [
            "crowdsecurity/nginx"
            "LePresidente/authelia" # Authelia brute force detection
            "gauth-fr/immich" # Immich brute force detection
            "crowdsecurity/nextcloud" # Nextcloud brute force detection
            "crowdsecurity/linux"
            "crowdsecurity/http-cve" # Adds protection against known web exploits
          ];
          parsers = [
            "crowdsecurity/sshd-logs"
            "crowdsecurity/whitelists"
          ];
          postoverflows = [
            "crowdsecurity/auditd-nix-wrappers-whitelist-process" # Ignore benign Nix wrapper execs
          ];
        };

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
            labels.type = "immich";
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=immich-server.service" ];
          }
          {
            labels.type = "authelia";
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=authelia-main.service" ];
          }
          {
            labels.type = "nextcloud";
            source = "journalctl";
            journalctl_filter = [ "SYSLOG_IDENTIFIER=Nextcloud" ];
          }
          {
            labels.type = "syslog";
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          }
        ];

        settings.config.api.server.online_client.credentials_path =
          "/var/lib/crowdsec/data/online_api_credentials.yaml";

        settings.console = {
          enrollKeyFile = config.age.secrets.crowdsec_token.path;
        };
      };

      services.crowdsec-firewall-bouncer.enable = true;

      age.secrets.crowdsec_token = {
        file = ../../../../secrets/crowdsec_token.age;
      };
    };
}
