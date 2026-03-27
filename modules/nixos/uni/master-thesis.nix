{
  flake.nixosModules.master-thesis = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      vscodium
    ];
    services.udev.packages = [ pkgs.python3Packages.chipwhisperer ];
  };
}
