{
  inputs,
  self,
  ...
}:
{
  perSystem = { pkgs, system, ... }: {
    packages.ashell = inputs.wrapper-modules.lib.wrapPackage ({ config, lib, ... }: {
      inherit pkgs; 
      package = inputs.ashell.packages.${pkgs.stdenv.hostPlatform.system}.default;
      binName = "ashell";
      flags = {
        "--config-path" = "${./config.toml}";
      };
    });
  };
}
