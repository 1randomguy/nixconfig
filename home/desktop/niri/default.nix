{ lib, config, pkgs, ... }: 
let
  cfg = config.desktop.niri;
in
{
  options.desktop.niri = {
    enable = lib.mkEnableOption "enable Niri desktop config";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/niri/config.kdl" = { source = ./config.kdl; };
    home.packages = with pkgs; [ 
      xwayland-satellite 
      xwayland-run 
      cage 
      brightnessctl 
      swaylock
      fuzzel
    ];
  };
}
