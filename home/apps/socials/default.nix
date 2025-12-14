{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.apps.socials;
in
{
  options.apps.socials = {
    enable = mkEnableOption "Install socials";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
      (signal-desktop.override {
        commandLineArgs = "--password-store=gnome-libsecret";
        withAppleEmojis = true;
      })
    ];
  };
}
