{
  inputs,
  self,
  ...
}:
{
  perSystem = { pkgs, system, ... }: {
    packages.ghostty = inputs.wrapper-modules.lib.wrapPackage ({ config, lib, ... }: {
      inherit pkgs; 
      package = pkgs.ghostty;
      binName = "ghostty";
    # home.packages = with pkgs; [
    #   wl-clipboard
    # ];
      flags = {
        "--config-file" = "${./config}";
      };
    });
  };
}
