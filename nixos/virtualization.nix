{...}:
{
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # temporary fix for https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220
  virtualisation.virtualbox.host.enableKvm = true;
  virtualisation.virtualbox.host.addNetworkInterface = false;

  users.extraGroups.vboxusers.members = [ "bene" ];
  virtualisation.waydroid.enable = true;
}
