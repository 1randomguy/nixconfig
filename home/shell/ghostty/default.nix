{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.shell.ghostty;
in
{
  options.shell.ghostty = {
    enable = mkEnableOption "ghostty shell";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        theme = "Catppuccin Mocha";
        font-size = 14;
        font-family = "JetBrainsMono";
        # keybind = [
        #   "ctrl+h=goto_split:left"
        #   "ctrl+l=goto_split:right"
        # ];
      };
    };
  };
}
