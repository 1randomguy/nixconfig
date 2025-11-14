{lib, config, pkgs, ...}:
let
 cfg = config.workstation.virtualization;
in
{
  options.workstation.virtualization = {
    enable = lib.mkEnableOption "Enable Virtualization";
    virtualbox.enable = lib.mkEnableOption "Enable VirtualBox";
    docker.enable = lib.mkEnableOption "Enable Docker";
    waydroid.enable = lib.mkEnableOption "Enable Waydroid";
    wine.enable = lib.mkEnableOption "Enable Wine";
  };

  config = lib.mkIf cfg.enable {
    
    # Virtualbox
    virtualisation.virtualbox.host = lib.mkIf cfg.virtualbox.enable {
      enable = true;
      enableExtensionPack = true;
      # temporary fix for https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220
      enableKvm = true;
      addNetworkInterface = false;
    };
    users.extraGroups.vboxusers.members = lib.mkIf cfg.virtualbox.enable [ "bene" ];

    virtualisation.waydroid.enable = cfg.waydroid.enable;

    virtualisation.docker.enable = cfg.docker.enable;

    environment.systemPackages = [
      pkgs.distrobox 
      #pkgs.podman-compose
    ] ++ lib.optionals cfg.wine.enable [
      pkgs.wineWowPackages.stable
      pkgs.winetricks
      pkgs.wineWowPackages.waylandFull
    ];
  };
}
