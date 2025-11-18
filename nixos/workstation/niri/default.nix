{ lib, config, ... }:
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
  };
}
