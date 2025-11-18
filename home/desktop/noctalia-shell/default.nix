{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.desktop.noctalia-shell;
in
{
  options.desktop.noctalia-shell = {
    enable = lib.mkEnableOption "enable noctalia-shell desktop config";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/noctalia/settings.json" = { source = ./settings.json; };
    home.file.".config/noctalia/colors.json" = { source = ./colors.json; };
    home.packages = with pkgs; [ 
      inputs.noctalia.packages.${system}.default
    ];
  };
}
