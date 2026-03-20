{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.workstation.games;
in
{
  options.workstation.games = {
    enable = lib.mkEnableOption "Enable Gaming";
    steam.enable = lib.mkEnableOption "Enable Steam";
    bottles.enable = lib.mkEnableOption "Enable Bottles and VN translation tools";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable32Bit = true;

    programs.steam = lib.mkIf cfg.steam.enable {
      enable = cfg.steam.enable;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    environment.systemPackages =
      with pkgs;
      [ gamescope ]
      ++ lib.optionals cfg.bottles.enable [
        bottles # The best manager for Wine prefixes
        wineWow64Packages.waylandFull # Modern Wine with Wayland support
        winetricks # To install Japanese fonts
        ipafont
      ];
  };
}
