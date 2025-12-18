{lib, config, ...}:
let
  cfg = config.homelab.services.prometheus;
  hl = config.homelab;
in
{
  options.homelab.services.prometheus = {
    enable = lib.mkEnableOption "Prometheus monitoring service";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "blocky";
          static_configs = [
            {
              targets = [ "localhost:9300" ];
            }
          ];
        }
      ];
    };

    services.nginx.virtualHosts."prometheus.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
      enableAuthelia = true;

      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.prometheus.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
