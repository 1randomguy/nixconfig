{
  flake.nixosModules.bentopdf =
    { config, ... }:
    let
      hl = config.homelab;
      domain = "bentopdf.${hl.baseDomain}";
    in
    {
      services.bentopdf = {
        enable = true;
        domain = domain;
        nginx.enable = true;
      };

      services.nginx.virtualHosts.domain = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        enableAuthelia = true;
      };
    };
}
