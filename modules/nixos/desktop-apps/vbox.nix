{
  flake.nixosModules.vbox = {pkgs, lib, ...}:
  {
    # Virtualbox
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
      # temporary fix for https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220
      # enableKvm = true;
      # addNetworkInterface = false;
    };
    users.extraGroups.vboxusers.members = [ "bene" ];
  };
}
