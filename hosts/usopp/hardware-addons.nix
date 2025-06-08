{pkgs, ...}:
{
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/data" = { 
    device = "/dev/disk/by-uuid/1888541B454557DE";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=media" "umask=000" ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
}
