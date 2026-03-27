{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.workstation;
in
{
  imports = [
    ./nfs-mount
    ./games
    ./gnome
    ./niri
    ./virtualization
    ./work
    ./uni-vpn
  ];
}
