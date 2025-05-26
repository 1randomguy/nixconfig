{pkgs, ...}:

{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    excludePackages = with pkgs; [
      xterm
    ];
  };
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    gnome-characters
    gnome-font-viewer
    gnome-software
    simple-scan
    yelp # help viewer
    gnome-weather
    gnome-maps
    gnome-contacts
  ];
  programs.dconf.enable = true;

  # keyboard
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "altgr-intl";
  #services.xserver.xkb.options = "eurosign:e,caps:escape";
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ anthy ];
  };
  environment.variables = {
    GLFW_IM_MODULE = "ibus";
    IBUS_ENABLE_SYNC_MODE = "1";
  };
  services.keyd = {
    enable = true;
    keyboards = {
    # The name is just the name of the configuration file, it does not really matter
    default = {
      ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
      # Everything but the ID section:
      settings = {
        # The main layer, if you choose to declare it in Nix
        main = {
          capslock = "overload(control, capslock)"; # you might need to also enclose the key in quotes if it contains non-alphabetical symbols
        };
        otherlayer = {};
      };
      extraConfig = ''
        # put here any extra-config, e.g. you can copy/paste here directly a configuration, just remove the ids part
      '';
    };
  };
  };

  # Optional, but makes sure that when you type the make palm rejection work with keyd
  # https://github.com/rvaiya/keyd/issues/723
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}
