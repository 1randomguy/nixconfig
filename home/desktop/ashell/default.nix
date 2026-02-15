{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.desktop.ashell;
in
{
  options.desktop.ashell = {
    enable = lib.mkEnableOption "enable ashell desktop config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ 
      #ashell
      inputs.ashell.packages.${stdenv.hostPlatform.system}.default
    ];

    home.file.".config/ashell/config.toml".source = ./config.toml;
  };
}
