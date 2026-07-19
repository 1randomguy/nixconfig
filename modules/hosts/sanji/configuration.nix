{ self, inputs, ... }:
{
  flake.nixosModules.sanjiConfiguration =
    { pkgs, lib, ... }:
    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.sanjiHardware

        self.nixosModules.common
        self.nixosModules.shell

        self.nixosModules.common-desktop
        self.nixosModules.gnome
        self.nixosModules.niri
        self.nixosModules.ashell
        self.nixosModules.vicinae

        self.nixosModules.base-apps
        self.nixosModules.extra-apps
        self.nixosModules.image-editing
        self.nixosModules.latex
        self.nixosModules.razer

        self.nixosModules.compat
        self.nixosModules.fonts
        self.nixosModules.master-thesis
        self.nixosModules.uni-vpn
        self.nixosModules.games
        self.nixosModules.local-llm
      ];

      games.bottles.enable = true;

      virtualisation.waydroid.enable = true;

      services.fprintd = {
        enable = true;
      };

      #security.pam.services.sudo.fprintAuth = false;
      #security.pam.services.su.fprintAuth = false;
      security.pam.services.hyprlock.fprintAuth = true;
      security.pam.services.login.fprintAuth = false;
      security.pam.services.gdm-password.fprintAuth = false;

      #networking.wg-quick.interfaces.wg0.configFile = "/home/bene/wireguard/wg_config.conf";

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };

      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/efi";
      boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

      environment.systemPackages = with pkgs; [
        sbctl
        inputs.agenix.packages."${stdenv.hostPlatform.system}".default
        libcamera
      ];

      networking.hostName = "sanji"; # Define your hostname.

      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.bene = {
        description = "Benedikt von Blomberg";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
          "networkmanager"
        ]; # Enable ‘sudo’ for the user.
      };

      swapDevices = [
        # {
        #   device = "/var/lib/swapfile";
        #   size = 32 * 1024; # 32 GiB
        #   options = [ "discard" ];
        # }
        {
          device = "/var/lib/swapfile2";
          size = 64 * 1024; # 64 GiB
          options = [ "discard" ];
        }
      ];

      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
