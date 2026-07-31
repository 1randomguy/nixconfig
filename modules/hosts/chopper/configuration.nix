{ self, inputs, ... }:
{
  flake.nixosModules.chopperConfiguration =
    { pkgs, config, ... }:

    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.chopperHardware

        self.nixosModules.common
        self.nixosModules.shell

        # disko
        inputs.disko.nixosModules.disko
        self.diskoConfigurations.chopper

        # homelab services
        self.nixosModules.homelab
        self.nixosModules.restic
        self.nixosModules.ddns-updater
        self.nixosModules.authelia
        self.nixosModules.blocky
        self.nixosModules.immich
        self.nixosModules.immich-auto-stacker
        self.nixosModules.immich-public-proxy
        self.nixosModules.gonic
        self.nixosModules.tinysub
        self.nixosModules.nextcloud
        self.nixosModules.bentopdf
        self.nixosModules.samba
        self.nixosModules.zola
        # TODO: relogin/setup
        # self.nixosModules.crowdsec
      ];

      homelab.baseDomain = "shimagumo.party";
      homelab.services.restic = {
        local.enable = true;
        local.targetDir = "/external/restic";
        s3.enable = true;
      };
      homelab.services.samba = {
        directory = "/public";
      };
      homelab.services.zola = {
        sourceOwner = "bene";
        sourceDir = "/home/bene/blog";
      };

      networking.hostName = "chopper"; # Define your hostname.
      networking.hostId = "8425e349"; # for zfs

      services.tailscale.extraUpFlags = "--advertise-routes=192.168.178.2/32";

      fileSystems."/external" = {
        device = "/dev/disk/by-uuid/a6b4a1b9-1a9b-47d4-b07a-e9fd9d25fe0a";
        fsType = "ext4";
      };
      # Ensure the subdirectories exist on the dataset before mounting
      boot.zfs.forceImportRoot = false;
      systemd.tmpfiles.rules = [
        "d /var/lib/immich-media/upload 0750 immich immich -"
        "d /var/lib/immich-media/library 0750 immich immich -"
        "d /var/lib/immich/upload 0750 immich immich -"
        "d /var/lib/immich/library 0750 immich immich -"
      ];
      environment.enableAllTerminfo = true;

      # Bind mounts for immich (to get same dataset for library and upload)
      fileSystems."/var/lib/immich/upload" = {
        device = "/var/lib/immich-media/upload";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/var/lib/immich-media" ];
      };
      fileSystems."/var/lib/immich/library" = {
        device = "/var/lib/immich-media/library";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/var/lib/immich-media" ];
      };
      fileSystems."/public/archive".depends = [ "/public" ];

      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.networks."eth" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "ipv4";
          # Enable SLAAC/Router Advertisements globally for this interface
          IPv6AcceptRA = true;
          IPv6PrivacyExtensions = "no";
        };
        dhcpV4Config = {
          ClientIdentifier = "mac";
        };
        # Configure the specific behavior of those Router Advertisements
        ipv6AcceptRAConfig = {
          Token = "::10";
        };
      };

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.bene = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "media"
        ]; # Enable ‘sudo’ for the user.
        hashedPassword = "$y$j9T$ZyKt7oLGpWR1x73ksSQ681$.BlXrMVAHUnzO4NUFE/IqWj46z17XM55uhv9Aecgkx7"; # make hash with mkpasswd
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILeR2HYD8+GXorP8MMI1MtvosGcY3x60056X/S8Sba7r bene" # desktop
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlNygbiGHOUNarDMe/RkT9sYSLakSswo/IWF2c0O5oR bene" # inspi
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCbATrAxuPLKk5UdhY5Jq9ONL+LQptpYgkisltGhu6R bene@sanji"
        ];
      };

      # Create media group
      users.groups.media = {
        gid = 505;
      };

      users.users.root.hashedPassword = "!"; # Locks the password field for root

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        inputs.agenix.packages."${stdenv.hostPlatform.system}".default
        powertop
        htop
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
