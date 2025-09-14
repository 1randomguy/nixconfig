{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.workstation.uni_vpn;
in
{
  options.workstation.uni_vpn = {
    enable = mkEnableOption "VPN for Uni";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      openconnect
    ];
    networking.networkmanager.plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };
}
