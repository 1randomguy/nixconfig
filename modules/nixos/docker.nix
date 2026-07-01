{ ... }:
{
  flake.nixosModules.docker =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = [ pkgs.distrobox ];
      virtualisation.docker.enable = true;
    };
}
