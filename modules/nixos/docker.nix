{...}:
{
  flake.nixosModules.docker = {pkgs, lib, ...}:
  {
    virtualisation.docker.enable = true;
  };
}
