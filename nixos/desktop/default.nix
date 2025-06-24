{lib, config, ...}:
with lib;
let
  cfg = config.homelab;
in
{
  imports = [
    ./nfs_mount
  ];

  options.homelab = {
    enable = mkEnableOption "Desktop config";
  };

  config = mkIf cfg.enable {
  };
}
