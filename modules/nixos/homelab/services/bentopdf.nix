{
  flake.nixosModules.bentopdf =
    { lib, config, ... }:
    let
      hl = config.homelab;
    in
    {
      services.bentopdf = {
        enable = true;
        domain = "bentopdf.${hl.baseDomain}";
        nginx = {
          enable = true;
          virtualHost = {
            # hostName = domain;
            enableACME = true;
            acmeRoot = null;
            forceSSL = true;
          };
        };
      };
      services.nginx.virtualHosts."bentopdf.${hl.baseDomain}".locations."~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$".extraConfig =
        lib.mkAfter ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload" always;
          add_header Referrer-Policy origin-when-cross-origin always;
          add_header X-Frame-Options DENY always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-Permitted-Cross-Domain-Policies "none" always;
        '';
    };
}
