{ self, inputs, ... }:
{
  flake.nixosModules.desktopConfiguration =
    { pkgs, config, ... }:
    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.desktopHardware

        self.nixosModules.common
        self.nixosModules.shell

        # self.nixosModules.common-desktop
        # self.nixosModules.gnome
        # self.nixosModules.niri
        # self.nixosModules.ashell
        # self.nixosModules.vicinae

        # self.nixosModules.base-apps
        # self.nixosModules.extra-apps
        # self.nixosModules.image-editing
        # self.nixosModules.latex
        #
        # self.nixosModules.compat
        # self.nixosModules.fonts
        # self.nixosModules.master-thesis
        # self.nixosModules.uni-vpn
        # self.nixosModules.games
        #
        # # self.nixosModules.nfs-mount
        # self.nixosModules.vbox
        # self.nixosModules.docker
      ];

      # services.flatpak.enable = true;
      # games.steam.enable = true;
      # services.xserver.videoDrivers = [ "nvidia" ];
      # hardware.nvidia = {
      #   modesetting.enable = true;
      #   powerManagement.enable = false;
      #   powerManagement.finegrained = false;
      #   open = false;
      #   nvidiaSettings = true;
      #   package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      # };
      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = 32 * 1024; # GiB
          options = [ "discard" ];
          priority = 200;
        }
        {
          device = "/home/bene/HDD/swapfile_2";
          size = 64 * 1024; # GiB
          priority = 0;
        }
      ];
      boot.zswap = {
        enable = true;
      };
      boot.kernel.sysctl = {
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "vm.page-cluster" = 0;
      };
      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
      # services.earlyoom.enable = true;
      # services.earlyoom.extraArgs = [
      #   "--avoid" "(^|/)(.+-)?(niri|Xwayland)$"
      #   "--prefer" "(^|/)(.+-)?(electron|chromium|firefox|teams)$"
      # ];
      services.nohang = {
        enable = true;
        configPath = "desktop";
      };
      security.rtkit.enable = true;

      # Open the UDP port for the magic packet inside your network
      networking.firewall.allowedUDPPorts = [ 9 ];
      # Systemd service to ensure wowlan is enabled on boot
      systemd.services.wake-on-wlan = {
        description = "Enable Wake-on-Wireless-LAN (WoWLAN)";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        requires = [ "network.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          # Note: Adjust phy0 if your command above returned a different number
          ExecStart = "${pkgs.iw}/bin/iw phy phy0 wowlan enable magic-packet";
        };
      };

      boot.extraModprobeConfig = ''
        options snd_hda_intel snoop=0 power_save=0
      '';

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/efi";
      boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

      #nixpkgs.config.allowUnfree = true;

      # hardware.graphics.enable = true;

      networking.hostName = "desktop"; # Define your hostname.
      networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

      # Set your time zone.
      time.timeZone = "Europe/Berlin";

      environment.systemPackages = with pkgs; [
        inputs.agenix.packages."${stdenv.hostPlatform.system}".default
      ];

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.bene = {
        description = "Benedikt von Blomberg";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "podman"
          "docker"
          "cdrom"
        ]; # Enable ‘sudo’ for the user.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILeR2HYD8+GXorP8MMI1MtvosGcY3x60056X/S8Sba7r bene" # desktop
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlNygbiGHOUNarDMe/RkT9sYSLakSswo/IWF2c0O5oR bene" # inspi
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCbATrAxuPLKk5UdhY5Jq9ONL+LQptpYgkisltGhu6R bene@sanji" # sanji
        ];
      };
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      # This option defines the first version of NixOS you have installed on this particular machine,
      # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
      #
      # Most users should NEVER change this value after the initial install, for any reason,
      # even if you've upgraded your system to a new NixOS release.
      #
      # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
      # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
      # to actually do that.
      #
      # This value being lower than the current NixOS release does NOT mean your system is
      # out of date, out of support, or vulnerable.
      #
      # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
      # and migrated your data accordingly.
      #
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "24.11"; # Did you read the comment?

    };
}
