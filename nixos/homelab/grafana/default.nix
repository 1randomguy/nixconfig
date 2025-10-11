{lib, config, pkgs, ...}:
let
  cfg = config.homelab.services.grafana;
  hl = config.homelab;
  blockyDashboard = pkgs.fetchurl {
    url = "https://grafana.com/api/dashboards/12777/revisions/1/download";
    sha256 = "1xzayyn9zxpcr3kcvp6pxr0dgdwjvzgizls3dx0zvz49hqdggdqx";
  };
  dashboardDir = pkgs.runCommand "grafana-dashboards" {} ''
    mkdir -p $out
    cp ${blockyDashboard} $out/blocky.json
  '';
in
{
  options.homelab.services.grafana = {
    enable = lib.mkEnableOption "Grafana monitoring dashboard";
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings.server = {
        http_port = 3000;
        domain = "grafana.${hl.baseDomain}";
        root_url = "https://grafana.${hl.baseDomain}";
      };
      provision = {
        datasources = {
          settings = {
            datasources = [{
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://localhost:9090";
              isDefault = true;
            }];
          };
        };
        dashboards = {
          settings = {
            apiVersion = 1;
            providers = [{
              name = "default";
              orgId = 1;
              folder = "";
              type = "file";
              disableDeletion = false;
              editable = true;
              options = {
                path = dashboardDir;
              };
            }];
          };
        };
      };
    };

    services.nginx.virtualHosts."grafana.${hl.baseDomain}" = {
      enableACME = true;
      acmeRoot = null;
      forceSSL = true;
      enableAuthelia = true;

      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
