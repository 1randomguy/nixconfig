{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps.uni_vpn;
in
{
  options.apps.uni_vpn = {
    enable = mkEnableOption "VPN for Uni";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      openconnect
      networkmanager-openconnect
      networkmanagerapplet
    ];
  };
}
