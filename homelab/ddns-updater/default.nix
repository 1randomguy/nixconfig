{lib, config, ...}:
with lib;
let
  cfg = config.homelab.services.ddns-updater;
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
        CONFIG_FILEPATH = "/run/credentials/ddns-updater.service/config.json";
        SERVER_ENABLE = "no";
      };
    };

    systemd.services.ddns-updater.serviceConfig.LoadCredential = [
      # Format is "credential_name:absolute_path_to_source_file"
      "config.json:${config.age.secrets.ddns-updater.path}"
    ];

    age.secrets.ddns-updater = {
      file = ../../secrets/ddns-updater.age;
    };
  };
}
