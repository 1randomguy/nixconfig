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
        mouse-hide-while-typing = true;
        scrollback-limit = 1000000;
        window-save-state = "always";
        window-decoration = "none";
        shell-integration-features = "ssh-terminfo,ssh-env";
        
        keybind = [
          "performable:ctrl+h=goto_split:left"
          "performable:ctrl+j=goto_split:bottom"
          "performable:ctrl+k=goto_split:top"
          "performable:ctrl+l=goto_split:right"

          "ctrl+a>h=new_split:left"
          "ctrl+a>j=new_split:down"
          "ctrl+a>k=new_split:up"
          "ctrl+a>l=new_split:right"
          "ctrl+a>s=new_split:auto"
          "ctrl+a>f=toggle_split_zoom"

          "ctrl+a>c=new_tab"
          "ctrl+a>ctrl+n=next_tab"
          "ctrl+a>n=next_tab"
          "ctrl+a>ctrl+p=previous_tab"
          "ctrl+a>p=previous_tab"

          "super+r=reload_config"
        ];
      };
    };
  };
}
