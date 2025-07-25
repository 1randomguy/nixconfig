{config, ...}:
let
  hl = config.homelab;
in
{
  networking.firewall = {
    allowedTCPPorts = [
      53 # DNS server
#    config.services.adguard-exporter.exporterPort
    ];
    allowedUDPPorts = [
      53 # DNS server
    ];
  };

  services.adguardhome = {
    enable = true;
    port = 3000;
    extraArgs = [
# Router knows best, i.e. stop returning 127.0.0.1 for DNS calls for self
      "--no-etc-hosts"
    ];
    mutableSettings = false;
    settings = {
      # users = [{
      #   name = "admin";
      #   password =
      #     "$2a$10$4rSCa07722Xa9G8BXaBTP.HX973a4FiH7HXJ5Go0GIilPuR85KPLi";
      # }];
      dns = {
# bind_hosts = [ "0.0.0.0" ];
        upstream_dns = [
          "https://dns10.quad9.net/dns-query"
        ];
        bootstrap_dns =
          [ "9.9.9.10" "149.112.112.10" "2620:fe::10" "2620:fe::fe:10" ];
      };
      filtering = {
        rewrites = [
          {
            domain = "immich.shimagumo.party";
            answer = "192.168.178.57";
          }
          {
            domain = "adguard.shimagumo.party";
            answer = "192.168.178.57";
          }
          {
            domain = "usopp.shimagumo.party";
            answer = "192.168.178.57";
          }
          {
            domain = "auth.shimagumo.party";
            answer = "192.168.178.57";
          }
          {
            domain = "shimagumo.party";
            answer = "192.168.178.57";
          }
          {
            domain = "fritz.box";
            answer = "192.168.178.1";
          }
        ];
      };

      # user_rules = [
      #   "@@||skyads.ott.skymedia.co.uk^$client='192.168.1.112'"
#     #      "||www.bbc.com^$client='192.168.1.25'"
#     #      "||www.bbc.co.uk^$client='192.168.1.25'"
      #     "@@||skyads.ott.skymedia.co.uk^$important" # permits skyads, undoes the block in line 1
      #     "@@||stats.grafana.org^$important" # permits grafana stats
      # ];
    };
  };
  services.nginx.virtualHosts."adguard.${hl.baseDomain}" = {
    enableACME = true;
    acmeRoot = null;
    forceSSL = true;
    enableAuthelia = true;

    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.adguardhome.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        # Only allow local network access

        # IPv4
        allow 192.168.178.0/24;  # My home network
        allow 127.0.0.1;         # Localhost

        # IPv6
        allow ::/128;            # Localhost
        allow fc00::/7;          # ULA
        allow fe80::/10;         # Link-local

        deny all;                # Block everything else (internet)
      '';
    };
  };
}
