{ config, pkgs, inputs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.git = {
    enable = true;
    userName = "Benedikt von Blomberg";
    userEmail = "github@bvb.anonaddy.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "oauth";
    };
  };
  home.packages = with pkgs; [
    git
    git-credential-oauth
    inputs.nixvim.packages.${system}.default
    neofetch
    wget
    ranger
    tmux
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
    };

    history = {
      size = 10000;
    };

    initExtraFirst = ''
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
      [[ ! -f  ${./config/shell/p10k.zsh} ]] || source ${./config/shell/p10k.zsh}
    '';

    initExtra = ''
      bindkey "''${key[Up]}" up-line-or-search
      bindkey "''${key[Down]}" down-line-or-search
    '';

    #promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "colored-man-pages" "extract" ]; #"zsh-interactive-cd" needs fzf 
    };
  };
}
