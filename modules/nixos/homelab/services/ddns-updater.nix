{
  flake.nixosModules.ddns-updater =
    { config, ... }:
    {
      # TODO: run as homelab user?
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
