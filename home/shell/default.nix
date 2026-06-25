{ lib, config, inputs, pkgs, ... }:
with lib;
let
  cfg = config.shell;
in {
  imports = [
  ];

  ## OPTIONS
  options.shell = {
    #enable = mkEnableOption "all about that shell";
    shelltools = mkOption {
      type = types.bool;
      default = true;
      description = "Shell Tools for making the shell useful";
    };
    nixos = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable some keyboard shortcuts that only seem to work inside of nixos, not in wsl";
    };
    remote = mkOption {
      type = types.bool;
      default = false;
      description = "System only accessed remotely via ssh";
    };
  };

}
