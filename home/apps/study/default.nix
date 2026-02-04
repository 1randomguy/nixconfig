{lib, config, pkgs, inputs, ...}:
with lib;
let
  cfg = config.apps.study;
in
{
  options.apps.study = {
    enable = mkEnableOption "Install study tools";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # studying
      anki
      goldendict-ng
      inputs.gd-tools.packages.${pkgs.system}.default
      antimicrox
    ];
  };
}
