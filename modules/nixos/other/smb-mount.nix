{
  flake.nixosModules.smb-mount =
    {
      pkgs,
      config,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.cifs-utils ];

      age.secrets.smb-secrets = {
        file = ../../../secrets/smb_secrets.age;
      };

      fileSystems."/mnt/share" = {
        device = "//192.168.178.2/data";
        fsType = "cifs";
        options = [
          # Automatically mounts on first folder access, unmounts when idle
          "x-systemd.automount"
          "noauto"
          "x-systemd.idle-timeout=60"

          # Prevents boot hangs if network is unavailable
          "_netdev"
          "nofail"

          # Permissions and credentials
          "credentials=${config.age.secrets.smb-secrets.path}"
          "uid=1000"
          "gid=100"
          "file_mode=0770"
          "dir_mode=0770"
        ];
      };
    };
}
