{
  flake.nixosModules.blocky =
    { ... }:
    {

      networking.firewall = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };

      services.resolved.enable = false;

      services.blocky = {
        enable = true;
        settings = {
          upstreams = {
            groups = {
              default = [
                "https://dns10.quad9.net/dns-query"
                "tcp-tls:dns10.quad9.net:853"
                "tcp-tls:1.1.1.1:853"
                "tcp-tls:1.0.0.1:853"
              ];
            };
          };
          bootstrapDns = [
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"
          ];
          blocking = {
            denylists = {
              multi = [
                "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/normal.txt"
                "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/tif.txt"
              ];
            };
            clientGroupsBlock = {
              default = [ "multi" ];
            };
          };
          customDNS = {
            mapping = {
              "shimagumo.party" = "192.168.178.2";
              "fritz.box" = "192.168.178.1";
            };
          };
          #prometheus = {
          #  enable = true;
          #  port = 9300;
          #};
        };
      };
    };
}
