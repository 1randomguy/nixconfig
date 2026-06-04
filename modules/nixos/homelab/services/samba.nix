{
  flake.nixosModules.samba =
    { lib, config, ... }:
    with lib;
    let
      cfg = config.homelab.services.samba;
    in
    {
      options.homelab.services.samba = {
        directory = mkOption {
          type = types.str;
          description = "The directory on the server to share";
          default = "/data";
        };
      };

      config = {
        # CAREFUL: you need to run `smbpasswd -a my_user`
        services.samba = {
          enable = true;
          openFirewall = true; # Automatically opens TCP 139, 445 and UDP 137, 138

          settings = {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "Benes Samba Server";
              "netbios name" = "Benes Samba Server";
              "security" = "user";
              # "use sendfile" = "yes";
              # "max protocol" = "smb2";
              
              # allow local and tailscale devices to connect
              "hosts allow" = "192.168.178.0/24 100.64.0.0/10 127.0.0.1 localhost";
              "hosts deny" = "0.0.0.0/0";
              # guest handling
              "guest account" = "nobody";
              "map to guest" = "bad user";
            };

            "data" = {
              "path" = cfg.directory;
              "browseable" = "yes";
              "read only" = "no";
              "guest ok" = "no"; # Set to "yes" if you don't want password prompts
              # Replicating your tmpfiles ownership (bene:users)
              "force user" = "bene";
              "force group" = "users";
              "create mask" = "0664";
              "directory mask" = "0775";
            };
          };
        };

        # Apple / Linux Network Discovery
        system.nssModules = with pkgs; [ avahi ];
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
          publish = {
            enable = true;
            userServices = true;
            workstation = true;  
          };
          extraServiceFiles = {
            smb = ''
              <?xml version="1.0" standalone='no'?><!DOCTYPE service-group SYSTEM "avahi-service.dtd">
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

        # Windows Network Discovery
        services.samba-wsdd = {
          enable = true;
          openFirewall = true;
        };

        homelab.services.restic.backupDirs = [ cfg.directory ];
      };
    };
}
