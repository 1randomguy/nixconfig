{
  inputs,
  self,
  ...
}:
{
  perSystem = { pkgs, system, ... }: {
    packages.kanshi = inputs.wrapper-modules.lib.wrapPackage ({ config, lib, ... }: {
      inherit pkgs; 
      package = pkgs.kanshi;
      binName = "kanshi";
      flags = {
        "--config" = "${./config}";
      };
    });
  };
}
