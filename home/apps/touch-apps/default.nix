{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps.touch_apps;
in
{
  options.apps.touch_apps = {
    enable = mkEnableOption "Install notetaking apps for touchscreen";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xournalpp
      rnote
    ];
  };
}
