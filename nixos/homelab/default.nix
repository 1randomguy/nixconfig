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
    #./restic
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
      networking.firewall.enable = true;
      networking.firewall.allowPing = true;
    };

    age.secrets.porkbun = {
      file = ../../../secrets/porkbun.age;
    };
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "bblomberg123@gmail.com";
      certs."shimagumo.party" = {
        dnsProvider = "porkbun";
        environmentFile = config.age.secrets.porkbun.path;
      };
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
