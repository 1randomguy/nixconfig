{ inputs, ... }:
{
  flake.nixosModules.tinysub =
    { config, pkgs, ... }:
    let
      hl = config.homelab;
      tinysubPkg = inputs.tinysub.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      services.nginx.virtualHosts."tinysub.${hl.baseDomain}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        enableAuthelia = true;

        root = "${tinysubPkg}";

        locations."/" = {
          index = "index.html";
          tryFiles = "$uri $uri/ /index.html";
        };
      };
    };
}
