{lib, config, pkgs, ...}:
with lib;
let
 cfg = config.workstation.virtualization;
in
{
  options.workstation.virtualization = {
    enable = mkEnableOption "Enable Virtualization";
    virtualbox.enable = mkEnableOption "Enable VirtualBox";
    docker.enable = mkEnableOption "Enable Docker";
    waydroid.enable = mkEnableOption "Enable Waydroid";
    wine.enable = mkEnableOption "Enable Wine";
  };

  config = mkIf cfg.enable {
    
    # Virtualbox
    virtualisation.virtualbox.host = mkIf cfg.virtualbox.enable {
      enable = true;
      enableExtensionPack = true;
      # temporary fix for https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220
      enableKvm = true;
      addNetworkInterface = false;
    };
    users.extraGroups.vboxusers.members = mkIf cfg.virtualbox.enable [ "bene" ];

    virtualisation.waydroid.enable = cfg.waydroid.enable;

    virtualisation.docker.enable = cfg.docker.enable;

    environment.systemPackages = mkIf cfg.wine.enable [
      pkgs.wineWowPackages.stable
      pkgs.winetricks
      pkgs.wineWowPackages.waylandFull
      #flatpak
    ];

    #services.flatpak.enable = true;
  };
}
