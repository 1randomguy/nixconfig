{config, ...}:
{
  services.immich = {
    enable = true;
    port = 2283;
    # `null` will give access to all devices.
    # You may want to restrict this by using something like `[ "/dev/dri/renderD128" ]`
    accelerationDevices = null;
    environment = {
      UPLOAD_LOCATION = "/data/immich_uploads";
    };
  };

  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    extraGroups = [ "video" "render" "media" ];
  };

}
