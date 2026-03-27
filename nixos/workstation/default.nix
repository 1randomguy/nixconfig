{lib, config, pkgs, ...}:
{
  imports = [
    ./nfs-mount
    ./games
    ./gnome
    ./niri
    ./virtualization
    ./work
  ];
}
