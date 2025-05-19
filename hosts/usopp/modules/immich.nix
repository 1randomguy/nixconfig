{config, ...}:
{
  # `null` will give access to all devices.
  # You may want to restrict this by using something like `[ "/dev/dri/renderD128" ]`
  services.immich.accelerationDevices = null;

  users.users.immich.extraGroups = [ "video" "render" ];

}
