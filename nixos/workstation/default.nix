{lib, config, pkgs, ...}:
with lib;
let
  cfg = config.workstation;
in
{
  imports = [
    ./nfs-mount
    ./games
    ./gnome
    ./virtualization
    ./work
    ./uni-vpn
  ];

  options.workstation = {
    enable = mkEnableOption "Workstation/Client machine config";
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        jetbrains-mono 
        nerd-fonts.jetbrains-mono
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];
      fontconfig = {
        defaultFonts = {
          monospace = [ "JetBrainsMono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
