{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.workstation.work;
in
{
  options.workstation.work = {
    enable = mkEnableOption "Enable setup for work";
  };

  config = mkIf cfg.enable {
    age.secrets.work_wireguard_sk = {
      file = ../../../secrets/wireguard_work.secret;
    };
    networking.firewall = {
      allowedUDPPorts = [ 52020 ];
    };
    networking.wireguard.interfaces.wg0 = {
      listenPort = 52020;

      ips = [ "<IP>/32" ];
      privateKeyFile = config.age.secrets.work_wireguard_sk.path;
      peers = [
        {
          publicKey = "Z87+fvuCrO0W/EPwNubTq8BXHb72ahwFIBzCqH9Xex8=";
          allowedIPs = [ "192.168.2.1/24" ];
          endpoint = "vpn-sanctuary.germanywestcentral.cloudapp.azure.com:52020";
          #persistentKeepalive = 25;
        }
      ];
    };
  };
}
