{lib, config, ...}:
with lib;
let
  cfg = config.homelab.services.ddclient;
  hl = config.homelab;
in
{
  options.homelab.services.ddclient = {
    enable = mkEnableOption "DDClient for dynamic DNS updates";
  };

  config = mkIf cfg.enable {
    services.ddclient = {
      enable = true;
      interval = "5m";
      configFile = config.age.secrets.ddclient_config.path;
    };

    age.secrets.ddclient_config = {
      file = ../../../secrets/ddclient_config.age;
    };
  };
}
