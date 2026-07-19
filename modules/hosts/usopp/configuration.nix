{ self, inputs, ... }:
{
  flake.nixosModules.usoppConfiguration =
    { pkgs, ... }:

    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.usoppHardware

        self.nixosModules.common
        self.nixosModules.shell

        # disko
        inputs.disko.nixosModules.disko
        self.diskoConfigurations.usopp

        # homelab services
        self.nixosModules.homelab
        self.nixosModules.restic
        self.nixosModules.ddns-updater
        self.nixosModules.authelia
        self.nixosModules.blocky
        self.nixosModules.immich
        self.nixosModules.immich-auto-stacker
        self.nixosModules.immich-public-proxy
        self.nixosModules.navidrome
        self.nixosModules.nextcloud
        self.nixosModules.bentopdf
        self.nixosModules.samba
        self.nixosModules.zola
        self.nixosModules.crowdsec
      ];

      homelab.baseDomain = "shimagumo.party";
      homelab.services.restic = {
        local.enable = true;
        local.targetDir = "/data/restic";
        s3.enable = true;
      };
      homelab.services.samba = {
        directory = "/public";
      };
      homelab.services.zola = {
        sourceOwner = "bene";
        sourceDir = "/home/bene/blog";
      };

      services.tailscale.extraUpFlags = "--advertise-routes=192.168.178.57/32";

      networking.useNetworkd = true;
      systemd.network.enable = true;

      systemd.network.networks."wlan" = {
        matchConfig.Name = "wlp2s0";
        networkConfig = {
          # Enable SLAAC/Router Advertisements globally for this interface
          IPv6AcceptRA = true;
        };
        # Configure the specific behavior of those Router Advertisements
        ipv6AcceptRAConfig = {
          Token = "::10";
        };
      };

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "usopp"; # Define your hostname.

      # Create media group
      users.groups.media = { };

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.bene = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "media"
        ]; # Enable ‘sudo’ for the user.
        hashedPassword = "$y$j9T$N5EIjQO22iiuXI5EMl8vg0$6OoYpdXTPkiVI20iXzuPt2dF8o3pQmrwPEEdn2ILZP."; # make hash with mkpasswd
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILeR2HYD8+GXorP8MMI1MtvosGcY3x60056X/S8Sba7r bene" # desktop
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlNygbiGHOUNarDMe/RkT9sYSLakSswo/IWF2c0O5oR bene" # inspi
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCbATrAxuPLKk5UdhY5Jq9ONL+LQptpYgkisltGhu6R bene@sanji" # sanji
        ];
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget
        powertop
        htop
        inputs.agenix.packages."${stdenv.hostPlatform.system}".default
        smartmontools
      ];

      # List services that you want to enable:
      programs.mosh.enable = true;
      services.vnstat.enable = true;
      services.smartd = {
        enable = true;
        notifications.wall.enable = true;
      };

      system.stateVersion = "24.11"; # Did you read the comment?
    };
}
