{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.workstation.thesis_tools;
in
{
  options.workstation.thesis_tools = {
    enable = mkEnableOption "Tools for my Master Thesis";
  };
  config = mkIf cfg.enable {
    # Enable uaccess for ChipWhisperer devices
    services.udev.packages = [ pkgs.python3Packages.chipwhisperer ];
  };
}
