{pkgs, ...}:
{
  fileSystems."/data" = { 
    device = "/dev/disk/by-uuid/a6b4a1b9-1a9b-47d4-b07a-e9fd9d25fe0a";
    fsType = "ext4";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
}
