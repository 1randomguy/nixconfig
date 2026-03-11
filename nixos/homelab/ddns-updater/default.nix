{lib, config, ...}:
with lib;
let
  cfg = config.homelab.services.ddclient;
  hl = config.homelab;
in
{
  options.homelab.services.ddns-updater = {
    enable = mkEnableOption "ddns-updater for dynamic DNS updates";
  };

  config = mkIf cfg.enable {
    services.ddns-updater = {
      enable = true;
      environment = {
        PERIOD = "5m";
        CONFIG_FILEPATH = config.age.secrets.ddns-updater.path;
      };
    };

    age.secrets.ddclient_config = {
      file = ../../../secrets/ddns-updater.age;
    };
  };
}
