{
  inputs,
  self,
  ...
}:
{
  perSystem = { pkgs, system, ... }: {
    packages.ashell = inputs.wrapper-modules.lib.wrapPackage ({ config, lib, ... }: {
      inherit pkgs; 
      package = pkgs.hyprlock;
      binName = "hyprlock";
      flags = {
        "--config" = "${./hyprlock.conf}";
      };
    });
  };
}
