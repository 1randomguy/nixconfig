{self, ...}:
{
  flake.nixosModules.ai-jail = {pkgs, ...}:
  {
    environment.systemPackages = [
      self.packages."${pkgs.stdenv.hostPlatform.system}".ai-jail
    ];
  };
}
