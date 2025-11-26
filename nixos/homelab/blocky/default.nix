{lib, config, ...}:
let
  cfg = config.homelab.services.blocky;
in
{
  options.homelab.services.blocky = {
    enable = lib.mkEnableOption "Blocky DNS server";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    services.blocky = {
      enable = true;
      settings = {
        upstream = {
          external = [
            "https://dns10.quad9.net/dns-query"
          ];
        };
        bootstrapDns = [
          "9.9.9.10"
          "149.112.112.10"
          "2620:fe::10"
          "2620:fe::fe:10"
        ];
        blocking = {
          blackLists = {
            ads = [
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/pro.txt"
            ];
            malware = [
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/threat-intelligence.txt"
            ];
          };
          clientGroupsBlock = {
            default = [ "ads" "malware" ];
          };
        };
        customDNS = {
          mapping = {
            "*.shimagumo.party" = "192.168.178.57";
            "shimagumo.party" = "192.168.178.57";
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
