{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps.latex;
in
{
  options.apps.latex = {
    enable = mkEnableOption "Install all Latex stuff";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      texlive.combined.scheme-full
      texworks
      zathura
      # kile
      kile
      ghostscript_headless
    ];
  };
}
