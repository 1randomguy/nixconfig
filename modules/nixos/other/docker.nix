{ ... }:
{
  flake.nixosModules.docker =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.distrobox ];
      virtualisation.docker.enable = true;
    };
}
