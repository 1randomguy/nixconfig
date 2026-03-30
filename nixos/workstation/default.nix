{lib, config, pkgs, ...}:
{
  imports = [
    ./nfs-mount
    ./games
    ./virtualization
    ./work
  ];
}
