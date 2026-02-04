{ lib, config, pkgs, ... }:
let
  cfg = config.desktop.ashell;
in
{
  options.desktop.ashell = {
    enable = lib.mkEnableOption "enable ashell desktop config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ 
      ashell
    ];

    home.file.".config/ashell/config.toml".source = ./config.toml;
  };
}
