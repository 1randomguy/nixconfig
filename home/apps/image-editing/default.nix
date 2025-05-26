{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps.image_editing;
in
{
  options.apps.image_editing = {
    enable = mkEnableOption "Image editing programs";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      darktable
      gimp
      inkscape
    ];
  };
}
