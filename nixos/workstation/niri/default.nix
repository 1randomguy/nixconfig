{ lib, config, pkgs, ... }:
let
  cfg = config.workstation.niri;
in
{
  options.workstation.niri = {
    enable = lib.mkEnableOption "Enable Niri";
  };

  config = lib.mkIf cfg.enable {
    ## for noctalia calender support:
    # services.gnome.evolution-data-server.enable = true;
    #
    # environment.systemPackages = with pkgs; [
    #   (python3.withPackages (pyPkgs: with pyPkgs; [ pygobject3 ]))
    #   phinger-cursors
    # ];
  };
}
