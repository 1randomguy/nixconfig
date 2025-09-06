{lib, config, pkgs, inputs, ...}:
with lib;
let
  cfg = config.apps;
in
{
  imports = [
    ./image-editing
    ./latex
    ./music
    ./touch-apps
    ./uni-vpn
    ./devel
    ./socials
  ];
  options.apps = {
    enable = mkEnableOption "Install graphical apps on this system";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # web
      firefox
      brave
      # image viewing, basic editing
      gthumb
      vlc
      # document editing
      libreoffice
      pdfarranger
      # studying
      anki
      antimicrox
      # system tools
      resources
      # other
      ausweisapp
      foliate
      nextcloud-client
    ];
  };
}
