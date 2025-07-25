{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.homelab.services.smb;
in
{
  options.homelab.services.smb = {
    enable = mkEnableOption "SMB Fileshare";
    directory = mkOption {
      type = types.str;
      description = "The directory on the server to share";
      default = "/data";
    };
  };
  config = mkIf cfg.enable {
    services.samba = {
      #package = pkgs.sambaFull;
      enable = true;

      securityType = "user";
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.178. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "private" = {
          "path" = cfg.directory;
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          #"force user" = "username";
          #"force group" = "groupname";
        };
      };
    };

    system.nssModules = with pkgs; [ avahi ];
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
        workstation = true;  # Publishes machine as a "workstation"
      };
      # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
      nssmdns4 = true;
      # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
      openFirewall = true;
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';
      };
      extraConfig = ''
        [server]
        use-ipv4=yes
        use-ipv6=no
      '';
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      cifs-utils
    ];
  };
}
