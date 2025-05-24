{ pkgs, lib, config, ... }:
with lib;
let 
  sh = config.shell;
  cfg = config.shell.zsh;
  p10k_shellconf = if cfg.p10k
  then
    ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
        [[ ! -f  ${./config/p10k.zsh} ]] || source ${./config/p10k.zsh}
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
    ''
  else
    "";
in
{
  options.shell.zsh = {
    enable = mkEnableOption "zsh";
    p10k = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable powerlevel10k prompt";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    home.packages = mkIf cfg.p10k [
      pkgs.any-nix-shell
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
      };

      initExtra = mkIf sh.nixos ''
        bindkey "''${key[Up]}" up-line-or-search
        bindkey "''${key[Down]}" down-line-or-search
      '';

      plugins = builtins.filter(x: x != null) [
        ( if cfg.p10k then 
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
        else null )
        {
          name = "you-should-use";
          src = pkgs.zsh-you-should-use;
          file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
        }
      ];

      initContent = mkBefore p10k_shellconf;

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "colored-man-pages" "extract" "tmux" ];
      };
    };
  };
}
