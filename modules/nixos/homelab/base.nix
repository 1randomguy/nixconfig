{
  flake.nixosModules.homelab =
    {
      config,
      pkgs,
      ...
    }:
    let
    in
    {
      services.nohang.configPath = "basic";

      networking.firewall.enable = true;
      networking.firewall.allowPing = true;
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      age.secrets.ntfy_url = {
        file = ../../../secrets/ntfy_url.age;
      };

      services.postgresql.enable = true;

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
      systemd.services.nixos-upgrade.serviceConfig.ExecStopPost =
        "${pkgs.writeShellScript "upgrade-notify" ''
          WEBHOOK_URL=$(cat ${config.age.secrets.ntfy_url.path})

          CURRENT_SYS=$(readlink /run/current-system)
          NEW_SYS=$(readlink /nix/var/nix/profiles/system)

          if [ "$EXIT_STATUS" = "0" ]; then
            # Only notify if the system path actually changed
            if [ "$CURRENT_SYS" != "$NEW_SYS" ]; then
              ${pkgs.curl}/bin/curl \
                -H "Title: NixOS Upgrade Success" \
                -H "Tags: white_check_mark" \
                -d "Server updated successfully to the latest GitHub commit." \
                "$WEBHOOK_URL"
            else
              echo "No changes detected in the flake. Staying quiet."
            fi
          else
            # Grab the last 50 lines of the journal on failure
            ${pkgs.systemd}/bin/journalctl -u nixos-upgrade.service -n 50 --no-pager | \
            ${pkgs.curl}/bin/curl \
              -H "Title: NixOS Upgrade FAILED" \
              -H "Tags: warning" \
              -d @- \
              "$WEBHOOK_URL"
          fi
        ''}";

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
