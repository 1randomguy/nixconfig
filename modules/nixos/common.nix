{
  flake.nixosModules.common = { pkgs, lib, ... }: {
    i18n.supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "en_DK.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LANG = "en_US.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "en_DK.UTF-8";
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "en_DK.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_COLLATE = "de_DE.UTF-8";
    };

    # Set your time zone.
    time.timeZone = lib.mkDefault "Europe/Berlin";

    # Select internationalisation properties.
    console.keyMap = lib.mkDefault "us";

    networking.networkmanager.enable = lib.mkDefault true; # Easiest to use and most distros use this by default.

    services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    boot.zswap = {
      enable = true;
    };
    boot.kernel.sysctl = {
      "vm.swappiness" = 70;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
      "vm.page-cluster" = 0;
    };
    services.nohang = {
      enable = true;
    };

    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "8192";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "65536";
      }
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    nix.optimise.automatic = true;
    services.tailscale.enable = true;
  };
}
