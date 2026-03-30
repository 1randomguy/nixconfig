{lib, config, pkgs, ...}:
{
  imports = [
    ./nfs-mount
    ./games
    ./gnome
    ./virtualization
    ./work
  ];
}
