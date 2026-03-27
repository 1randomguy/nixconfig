{
  flake.nixosModules.uni-vpn = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      openconnect
    ];
    networking.networkmanager.plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };
}
