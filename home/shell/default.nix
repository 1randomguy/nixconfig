{ lib, config, ... }:
with lib;
let
  cfg = config.shell;
in {
  imports = [
    ./modules/shell-tools.nix
    ./zsh/default.nix
  ];
  options.services.shell = {
    #enable = mkEnableOption "all about that shell";
  };
}
