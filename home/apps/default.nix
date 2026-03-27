{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps;
in
{
  imports = [
    ./music
  ];
  options.apps = {
    enable = mkEnableOption "Install graphical apps on this system";
  };
  config = mkIf cfg.enable {
  };
}
