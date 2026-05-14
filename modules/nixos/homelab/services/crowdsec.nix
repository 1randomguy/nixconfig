{
  flake.nixosModules.ddns-updater =
    { config, ... }:
    {
      services.crowdsec = {
        enable = true;
        # ... your other crowdsec settings ...

        settings.console = {
          tokenFile = config.age.secrets.crowdsec_token.path;

          configuration = {
            share_manual_decisions = true;
            share_tainted = true;
            console_management = false; # Keep NixOS in control of your config
            share_context = true;
          };
        };
      };

      age.secrets.crowdsec_token = {
        file = ../../../../secrets/crowdsec_token.age;
      };
    };
}
