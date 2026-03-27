{ self, ... }:
{
  flake.nixosModules.shell = {pkgs, ...}:
  let
    selfpkgs = self.packages."${pkgs.system}";
  in
  {
    environment.systemPackages = [
      selfpkgs.neovim
    ];
  };
}
