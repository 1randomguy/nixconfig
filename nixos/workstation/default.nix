{lib, config, ...}:
with lib;
let
  cfg = config.workstation;
in
{
  imports = [
    ./nfs_mount
  ];

  options.workstation = {
    enable = mkEnableOption "Workstation/Client machine config";
  };

  config = mkIf cfg.enable {
  };
}
