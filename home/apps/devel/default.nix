{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps.devel;
in
{
  options.apps.devel = {
    enable = mkEnableOption "gui apps for development";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gitg
    ];
  };
}
