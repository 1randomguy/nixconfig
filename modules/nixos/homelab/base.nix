{
  flake.nixosModules.homelab =
    {
      config,
      lib,
      ...
    }:
    {
      services.nohang.configPath = "basic";

      networking.firewall.enable = true;
      networking.firewall.allowPing = true;
      networking.firewall.trustedInterfaces = [
        "docker0"
      ];
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.postgresql.enable = true;

      homelab.services.restic.backupDirs = [
        "/var/lib/tailscale"
      ] ++ lib.optionals config.services.openssh.enable (
        lib.concatMap (key: [ key.path "${key.path}.pub" ]) config.services.openssh.hostKeys
      );

      system.autoUpgrade = {
        enable = true;
        flake = "github:1randomguy/nixconfig#${config.networking.hostName}";
        dates = "Sat,Sun 08:00";
        flags = [
          "--refresh"
          "--no-write-lock-file"
        ];
        allowReboot = false;
      };

      age.secrets.porkbun = {
        file = ../../../secrets/porkbun.age;
      };

      security.acme = {
        acceptTerms = true;
        defaults = {
          email = "bblomberg123@gmail.com";
          dnsProvider = "porkbun";
          dnsResolver = "1.1.1.1:53";
          environmentFile = config.age.secrets.porkbun.path;
        };
      };
    };
}
