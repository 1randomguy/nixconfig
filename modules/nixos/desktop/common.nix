{self, ...}:
{
  flake.nixosModules.common = {pkgs, lib, ...}:
  let
    selfpkgs = self.packages."${pkgs.system}";
  in
  {
    # keyboard
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.variant = "altgr-intl";
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk      # GTK support
        #fcitx5-configtool # GUI for configuration
        qt6Packages.fcitx5-configtool
      ];
    };
    environment.variables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      #GTK_IM_MODULE = "fcitx";
      #QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
    };

    environment.sessionVariables = {
      GI_TYPELIB_PATH = lib.makeSearchPath "lib/girepository-1.0" (
        with pkgs;
        [
          evolution-data-server
          libical
          glib.out
          libsoup_3
          json-glib
          gobject-introspection
        ]
      );
    };

    services.displayManager.gdm.enable = true;
    services.keyd = {
      enable = true;
      # The name (default) is just the name of the configuration file, it does not really matter
      keyboards.default = {
        ids = [ 
          "0001:0001" # only the laptop keyboard (find uuid with `sudo keyd -m`)
          "17ef:608d" # Lenovo LiteOn
          "17ef:6099"
        ]; 
        settings = {
          # The main layer, if you choose to declare it in Nix
          main = {
            capslock = "layer(control)"; # you might need to also enclose the key in quotes if it contains non-alphabetical symbols
            insert = "layer(otherlayer)";
            leftalt = "layer(meta)";
            leftmeta = "layer(alt)";
          };
          otherlayer = {
            capslock = "capslock";
          };
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
  };
}
