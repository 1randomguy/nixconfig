{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.shell.zk;
in {
  options.shell.zk = {
    enable = mkEnableOption "enable zk for notetaking";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zk
      python312Packages.pylatexenc
    ];
  };
}
