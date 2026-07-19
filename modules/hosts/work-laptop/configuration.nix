# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ self, inputs, ... }:
{
  flake.nixosModules.worklaptopConfiguration =
    { pkgs, ... }:

    {
      imports = [
        # Include the results of the hardware scan.
        self.nixosModules.worklaptopHardware

        self.nixosModules.common
        self.nixosModules.shell

        self.nixosModules.common-desktop
        self.nixosModules.gnome
        self.nixosModules.niri
        self.nixosModules.ashell
        self.nixosModules.vicinae

        self.nixosModules.base-apps
        self.nixosModules.games

        self.nixosModules.compat
        self.nixosModules.fonts
        self.nixosModules.work
        self.nixosModules.docker
        #self.nixosModules.local-llm
      ];

      games.steam.enable = true;

      environment.systemPackages = [
        inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
        pkgs.polkit_gnome # Provides the graphical auth popup
      ];

      # Ensure Polkit is globally enabled
      security.polkit.enable = true;

      # Create a systemd user service to launch the agent automatically
      systemd.user.services.polkit-gnome-authentication-agent = {
        description = "polkit-gnome-authentication-agent";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "worklaptop"; # Define your hostname.

      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.bene = {
        description = "Benedikt von Blomberg";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "podman"
          "docker"
        ]; # Enable ‘sudo’ for the user.
      };

      system.stateVersion = "24.05"; # Did you read the comment?
    };
}
