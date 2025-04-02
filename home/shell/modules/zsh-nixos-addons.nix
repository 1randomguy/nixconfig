{...}:

{
  programs.zsh.initExtra = ''
    bindkey "''${key[Up]}" up-line-or-search
    bindkey "''${key[Down]}" down-line-or-search
  '';
}
