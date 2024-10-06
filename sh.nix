{ config, pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;


    history = {
      size = 10000;
    };

    initExtraFirst = ''
      [[ ! -f  ${./p10k.zsh} ]] || source ${./p10k.zsh}
    '';

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-completions"; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme ]; }
      ];
    };
  };
}
