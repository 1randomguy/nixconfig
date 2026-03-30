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

        self.nixosModules.gnome
        self.nixosModules.niri
        self.nixosModules.ashell

        self.nixosModules.base-apps
        self.nixosModules.extra-apps
        #self.nixosModules.image-editing
        self.nixosModules.latex

        self.nixosModules.compat
        self.nixosModules.fonts
        self.nixosModules.master-thesis
        self.nixosModules.uni-vpn
        self.nixosModules.games

        self.nixosModules.nfs-mount
        self.nixosModules.vbox
        self.nixosModules.docker
      ];

      nfs-mount = {
        enable = true;
        directory = "/home/bene/data";
      };
      games.steam.enable = true;
      games.bottles.enable = true;

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/efi";
      boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

      #nixpkgs.config.allowUnfree = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.production;
      };

      hardware.graphics.enable = true;
        
      networking.hostName = "desktop"; # Define your hostname.
      networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

      # Set your time zone.
      time.timeZone = "Europe/Berlin";

      environment.systemPackages = with pkgs; [
        inputs.agenix.packages."${stdenv.hostPlatform.system}".default
      ];

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.bene = {
        description = "Benedikt von Blomberg";
        isNormalUser = true;
        extraGroups = [ "wheel" "podman" "docker" ]; # Enable ‘sudo’ for the user.
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
