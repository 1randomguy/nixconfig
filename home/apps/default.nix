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
      chromium
      # organization
      evolution
      # image viewing, basic editing
      gthumb
      vlc
      # document viewing/editing
      libreoffice
      pdfarranger
      sioyek
      zotero
      kdePackages.okular
      # studying
      anki
      antimicrox
      # other
      ausweisapp
      foliate
      nextcloud-client
      protonvpn-gui
      typst
      # tools
      resources
      file-roller
      bluetui
    ];
  };
}
