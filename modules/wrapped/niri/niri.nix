{
  inputs,
  self,
  ...
}:
{
  perSystem = { pkgs, system, ... }: {
    packages.niri = inputs.wrapper-modules.lib.wrapPackage ({ config, lib, ... }: {
      inherit pkgs; 
      package = pkgs.niri;
      binName = "niri";
      flags = {
        "--config" = "${./config.kdl}";
      };
    });
  };
}
