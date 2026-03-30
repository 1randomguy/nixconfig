{
  inputs,
  self,
  ...
}:
{
  perSystem = { pkgs, system, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs; 
      "config.kdl".content = builtins.readFile ./config.kdl;
    };
  };
}
