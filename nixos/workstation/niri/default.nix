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
    ];

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
