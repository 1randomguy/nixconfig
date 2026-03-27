{
  flake.nixosModules.image-editing = {pkgs, ...}:
  {
    environment.systemPackages = with pkgs; [
      darktable
      gimp
      inkscape
    ];
  };
}
