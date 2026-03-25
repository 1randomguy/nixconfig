{ lib, config, pkgs, ... }:
let
  cfg = config.workstation.niri;
in
{
  options.workstation.niri = {
    enable = lib.mkEnableOption "Enable Niri";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    services.displayManager.defaultSession = "niri";

    ## for noctalia calender support:
    services.gnome.evolution-data-server.enable = true;

    environment.systemPackages = with pkgs; [
      (python3.withPackages (pyPkgs: with pyPkgs; [ pygobject3 ]))
      phinger-cursors
    ];

    # cursor
    #environment.systemPackages = [ pkgs.phinger-cursors ];
    environment.variables = {
      XCURSOR_THEME = "phinger-cursors-light";
      XCURSOR_SIZE = "32";
    };
    # This forces GTK3/GTK4 apps (including flatpaks) to respect the cursor
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          cursor-theme = "phinger-cursors-light";
          cursor-size = pkgs.lib.gvariant.mkInt32 32; 
        };
      };
    }];
    # This catches stubborn XWayland apps that ignore the environment variables
    environment.etc."X11/Xresources".text = ''
      Xcursor.theme: phinger-cursors-light
      Xcursor.size: 32
    '';

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
  };
}
