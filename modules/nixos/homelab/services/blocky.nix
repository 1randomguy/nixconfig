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
            strategy = "strict"; # Uses Quad9 100% of the time unless it fails -> then fallback to cloudflare
            groups = {
              default = [
                "tcp-tls:dns10.quad9.net:853"
                "tcp-tls:security.cloudflare-dns.com:853"
              ];
            };
          };
          # only resolve domain names of upstreams
          bootstrapDns = [ 
            "9.9.9.10"
            "1.1.1.2"
            "2620:fe::10"
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
