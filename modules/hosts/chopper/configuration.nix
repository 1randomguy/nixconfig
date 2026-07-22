{ self, inputs, ... }:
{
  flake.nixosModules.chopperConfiguration =
    { pkgs, ... }:

    {
      imports = [
        # Include the results of the hardware scan.
        # TODO: hardware
        self.nixosModules.chopperHardware

        self.nixosModules.common
        self.nixosModules.shell

        # disko
        inputs.disko.nixosModules.disko
        self.diskoConfigurations.chopper

        # TODO: add ssh key of chopper to agenix list and rekey

        # homelab services
        # self.nixosModules.homelab
        # self.nixosModules.restic
        # self.nixosModules.ddns-updater
        # # TODO: restore backup
        # self.nixosModules.authelia
        # self.nixosModules.blocky
        # # TODO: restore backup
        # self.nixosModules.immich
        # self.nixosModules.immich-auto-stacker
        # self.nixosModules.immich-public-proxy
        # # NOTE: change to gonic?
        # self.nixosModules.navidrome
        # # TODO: restore backup
        # self.nixosModules.nextcloud
        # self.nixosModules.bentopdf
        # self.nixosModules.samba
        # # TODO: restore backup
        # self.nixosModules.zola
        # # TODO: relogin/setup
        # # self.nixosModules.crowdsec
      ];

      # homelab.baseDomain = "shimagumo.party";
      # homelab.services.restic = {
      #   local.enable = true;
      #   local.targetDir = "/external/restic";
      #   s3.enable = true;
      # };
      # # TODO: set password
      # homelab.services.samba = {
      #   directory = "/public";
      # };
      # homelab.services.zola = {
      #   sourceOwner = "bene";
      #   sourceDir = "/home/bene/blog";
      # };
      #
      # # TODO: change IP to correct new IP (maybe 192.168.178.2?)
      # services.tailscale.extraUpFlags = "--advertise-routes=192.168.178.57/32";
      #
      # # TODO: maybe change uuid?
      # fileSystems."/external" = {
      #   device = "/dev/disk/by-uuid/a6b4a1b9-1a9b-47d4-b07a-e9fd9d25fe0a";
      #   fsType = "ext4";
      # };
      # Ensure the subdirectories exist on the dataset before mounting
      boot.zfs.forceImportRoot = false;
      systemd.tmpfiles.rules = [
        "d /var/lib/immich-media/upload 0750 immich immich -"
        "d /var/lib/immich-media/library 0750 immich immich -"
        "d /var/lib/immich/upload 0750 immich immich -"
        "d /var/lib/immich/library 0750 immich immich -"
      ];

      # Bind mount upload
      fileSystems."/var/lib/immich/upload" = {
        device = "/var/lib/immich-media/upload";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/var/lib/immich-media" ];
      };

      # Bind mount library
      fileSystems."/var/lib/immich/library" = {
        device = "/var/lib/immich-media/library";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/var/lib/immich-media" ];
      };
      fileSystems."/public/archive".depends = [ "/public" ];

      boot.initrd = {
        systemd = {
          enable = true;
          # Tell systemd-networkd inside initrd to request DHCP on Ethernet interfaces
          network = {
            enable = true;
            networks."10-eth" = {
              matchConfig.Name = "en*";
              networkConfig.DHCP = "ipv4";
            };
          };
        };
        availableKernelModules = [
          "igc" # Intel I226-V 2.5GbE NIC Driver (Crucial for initrd SSH)
          "ahci" # Intel Alder Lake-N SATA Controller
          "nvme" # M.2 NVMe Storage Driver
          "xhci_pci" # USB 3.0 Controllers
        ];

        network = {
          # This will use udhcp to get an ip address.
          # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`,
          # so your initrd can load it!
          # Static ip addresses might be configured using the ip argument in kernel command line:
          # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
          enable = true;
          ssh = {
            enable = true;
            # To prevent ssh clients from freaking out because a different host key is used,
            # a different port for ssh is useful (assuming the same host has also a regular sshd running)
            port = 2222;
            # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
            # the keys are copied to initrd from the path specified; multiple keys can be set
            # you can generate any number of host keys using
            # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
            hostKeys = [
              "/etc/secrets/initrd/ssh_host_ed25519_key"
            ];
            # public ssh key used for login
            authorizedKeys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILeR2HYD8+GXorP8MMI1MtvosGcY3x60056X/S8Sba7r bene" # desktop
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlNygbiGHOUNarDMe/RkT9sYSLakSswo/IWF2c0O5oR bene" # inspi
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCbATrAxuPLKk5UdhY5Jq9ONL+LQptpYgkisltGhu6R bene@sanji"
            ];
          };
        };
      };

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

      networking.hostName = "chopper"; # Define your hostname.
      networking.hostId = "8425e349";

      # Create media group
      users.groups.media = { };

      users.users.root.hashedPassword = "!"; # Locks the password field for root
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
