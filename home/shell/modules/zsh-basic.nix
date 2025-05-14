{ pkgs, lib, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

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

    initContent = lib.mkBefore ''
      ZSH_TMUX_AUTOSTART=false
    '';

    plugins = [
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "colored-man-pages" "extract" "tmux" ];
    };
  };
}
