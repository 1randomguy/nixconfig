{lib, config, ...}:
with lib;
let
  cfg = config.workstation.games;
in
{
  options.workstation.games = {
    enable = mkEnableOption "Enable Gaming";
    steam.enable = mkEnableOption "Enable Steam";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = cfg.steam.enable;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
