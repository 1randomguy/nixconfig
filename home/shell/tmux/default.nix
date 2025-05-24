{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.shell.tmux;
in
{
  options.shell.tmux = {
    enable = mkEnableOption "TMUX";
    full = mkOption {
      type = types.bool;
      default = true;
      description = "whether to enable full custom config";
    };
  };

  config = {
    programs.tmux = {
      enable = true;
      clock24 = true;
      mouse = true;
      #historyLimit = 5000;
      sensibleOnTop = true;
      shortcut = (if cfg.full then "s" else "b");
      terminal = "tmux-256color";
      extraConfig = ''
        set -as terminal-overrides ",xterm*:Tc"

        set -gq allow-passthrough on
        set -g visual-activity off
      '';
      plugins = with pkgs; [
        tmuxPlugins.tmux-fzf
        (if cfg.full then tmuxPlugins.catppuccin else null)
      ];
    };
  };
}
